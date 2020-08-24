-- ********************************************************************************** --
-- **                                                                                                                                                     ** --
-- **   Minecraft Mining Turtle Ore Quarry v0.2 by AustinKK                                             ** --
-- **   ---------------------------------------------------                                             ** --
-- **                                                                                                                                                     ** --
-- **   For instructions on how to use:                                                                                 ** --
-- **                                                                                                                                                     ** --
-- **     http://www.youtube.com/watch?v=DS1H4OY0yyg                               ** --
-- **                                                                                                                                                     ** --
-- ********************************************************************************** --
-- Enumeration to store the the different types of message that can be written
messageLevel = { DEBUG=0, INFO=1, WARNING=2, ERROR=3, FATAL=4 }

-- Enumeration to store names for the 6 directions
direction = { FORWARD=0, RIGHT=1, BACK=2, LEFT=3, UP=4, DOWN=5 }

local messageOutputLevel = messageLevel.INFO
local fuelLevelToRefuelAt = 5
local refuelItemsToUseWhenRefuelling = 1
local emergencyFuelToRetain = 3
local maximumGravelStackSupported = 25 -- The number of stacked gravel or sand blocks supported
local nonSeamBlocks
local bottomLayer = 5 -- The y co-ords of the layer immediately above bedrock
local returningToStart = false
local lookForChests = false -- Determines if chests should be located as part of the quarrying
local lastEmptySlot -- The last inventory slot that was empty when the program started (is either 15 if not looking for chests or 14 if we are)
local turtleId

-- Variables to store the current location and orientation of the turtle. x is right, left, y is up, down and
-- z is forward, back with relation to the starting orientation. Y is the actual turtle level, x and z are
-- in relation to the starting point (i.e. the starting point is (0, 0))
local currX
local currY
local currZ
local currOrient

-- Command line parameters
local startHeight -- Represents the height (y co-ord) that the turtle started at
local quarryWidth -- Represents the length of the mines that the turtle will dig

-- ********************************************************************************** --
-- Writes an output message
-- ********************************************************************************** --
function writeMessage(message, msgLevel)
  if (msgLevel >= messageOutputLevel) then
        print(message)
        if (turtleId == nil) then
          rednet.broadcast(message)
        else
          -- Broadcast the message (prefixed with the turtle's id)
          rednet.broadcast("[".. turtleId.."] "..message)
        end
  end
end

-- ********************************************************************************** --
-- Ensures that the turtle has fuel
-- ********************************************************************************** --
function ensureFuel()

  -- Determine whether a refuel is required
  local fuelLevel = turtle.getFuelLevel()
  if (fuelLevel ~= "unlimited") then
        if (fuelLevel < fuelLevelToRefuelAt) then
          -- Need to refuel
          turtle.select(16)
          local fuelItems = turtle.getItemCount(16)

          -- Do we need to impact the emergency fuel to continue? (always
          -- keep one fuel item in slot 16)
          if (fuelItems == 0) then
                writeMessage("Completely out of fuel!", messageLevel.FATAL)
          elseif (fuelItems == 1) then
                writeMessage("Out of Fuel!", messageLevel.ERROR)
          elseif (fuelItems <= (emergencyFuelToRetain + 1)) then
                writeMessage("Consuming emergency fuel supply. "..(fuelItems - 2).." emergency fuel items remain", messageLevel.WARNING)
                turtle.refuel(1)
          else
                -- Refuel the lesser of the refuelItemsToUseWhenRefuelling and the number of items more than
                -- the emergency fuel level
                if (fuelItems - (emergencyFuelToRetain + 1) < refuelItemsToUseWhenRefuelling) then
                  turtle.refuel(fuelItems - (emergencyFuelToRetain + 1))
                else
                  turtle.refuel(refuelItemsToUseWhenRefuelling)
                end
          end
        end
  end
end       

-- ********************************************************************************** --
-- Checks that the turtle has inventory space by checking for spare slots and returning
-- to the starting point to empty out if it doesn't.
--
-- Takes the position required to move to in order to empty the turtle's inventory
-- should it be full as arguments
-- ********************************************************************************** --
function ensureInventorySpace()

  -- If already returning to start, then don't need to do anything
  if (returningToStart == false) then

        -- If the last inventory slot is full, then need to return to the start and empty
        if (turtle.getItemCount(lastEmptySlot) > 0) then

          -- Return to the starting point and empty the inventory, then go back to mining
          returnToStartAndUnload(true)
        end
  end
end

-- ********************************************************************************** --
-- Function that is called when the turtle has returned to the start in order to
-- empty its inventory into the chest and also pick up any fuel that is
-- available
-- ********************************************************************************** --
function emptyInventory()

  local slotLoop = 1

  -- Face the chest
  turtleSetOrientation(direction.BACK)

  -- Loop over each of the slots (except the 16th one which stores fuel)
  while (slotLoop < 16) do
        -- If this is one of the slots that contains a noise block, empty all blocks except
        -- one
        turtle.select(slotLoop)
        if ((slotLoop <= nonSeamBlocks) or ((slotLoop == 15) and (lookForChests == true))) then
          turtle.drop(turtle.getItemCount(slotLoop) - 1)
        else
          -- Not a noise block, drop all of the items in this slot
          turtle.drop()
        end
        
        slotLoop = slotLoop + 1
  end

  -- While we are here, refill the fuel items
  turtleSetOrientation(direction.LEFT)
  turtle.select(16)
  local currFuelItems = turtle.getItemCount(16)
  turtle.suck()
  while ((currFuelItems ~= turtle.getItemCount(16)) and (turtle.getItemCount(16) < 64)) do
        currFuelItems = turtle.getItemCount(16)
        turtle.suck()
  end

  slotLoop = nonSeamBlocks + 1
  -- Have now picked up all the items that we can. If we have also picked up some
  -- additional fuel in some of the other slots, then drop it again
  while (slotLoop < lastEmptySlot) do
        -- Drop any items found in this slot
        turtle.select(slotLoop)
        turtle.drop()
        slotLoop = slotLoop + 1
  end

  -- Select the 1st slot because sometimes when leaving the 15th or 16th slots selected it can result
  -- in that slot being immediately filled (resulting in the turtle returning to base again too soon)
  turtle.select(1)
end

-- ********************************************************************************** --
-- Function to move to the starting point, call a function that is passed in
-- and return to the same location (if required)
-- ********************************************************************************** --
function returnToStartAndUnload(returnBackToMiningPoint)

  writeMessage("returnToStartAndUnload called", messageLevel.DEBUG)
  returningToStart = true

  -- Store the current location and orientation so that it can be returned to
  local storedX = currX
  local storedY = currY
  local storedZ = currZ
  local storedOrient = currOrient

  -- First direction to move is straight up. Do this because the inventory is full and
  -- therefore don't want to pass through any blocks that contain ores. Know that all
  -- blocks above don't contain ores, so is safe to go that way
  -- (Note, there is a rare edge case where the inventory becomes full after moving
  -- forward and before checking the block above, this is quite rare and given the
  -- likelihood of it not being able be added to the inventory (even though slot 15
  -- is full), and is deemed an acceptable risk)
  if (currY < startHeight) then
        while (currY < startHeight) do
          turtleUp()
        end
  elseif (currY > startHeight) then
        -- This should never happen
        writeMessage("Current height is greater than start height in returnToStartAndUnload", messageLevel.ERROR)
  end

  -- Move back to the correct X position
  if (currX > 0) then
        turtleSetOrientation(direction.LEFT)
        while (currX > 0) do
          turtleForward()
        end
  elseif (currX < 0) then
        -- This should never happen
        writeMessage("Current x is less than 0 in returnToStartAndUnload", messageLevel.ERROR)
  end

  -- Move back to the correct Z position
  if (currZ > 0) then
        turtleSetOrientation(direction.BACK)
        while (currZ > 0) do
          turtleForward()
        end
  elseif (currZ < 0) then
        -- This should never happen
        writeMessage("Current z is less than 0 in returnToStartAndUnload", messageLevel.ERROR)
  end

  -- Empty the inventory
  local slotLoop = 1

  -- Face the chest
  turtleSetOrientation(direction.BACK)

  -- Loop over each of the slots (except the 16th one which stores fuel)
  while (slotLoop < 16) do
        -- If this is one of the slots that contains a noise block, empty all blocks except
        -- one
        turtle.select(slotLoop)
        if ((slotLoop <= nonSeamBlocks) or ((slotLoop == 15) and (lookForChests == true))) then
          turtle.drop(turtle.getItemCount(slotLoop) - 1)
        else
          -- Not a noise block, drop all of the items in this slot
          turtle.drop()
        end
        
        slotLoop = slotLoop + 1
  end

  -- While we are here, refill the fuel items
  turtleSetOrientation(direction.LEFT)
  turtle.select(16)
  local currFuelItems = turtle.getItemCount(16)
  turtle.suck()
  while ((currFuelItems ~= turtle.getItemCount(16)) and (turtle.getItemCount(16) < 64)) do
        currFuelItems = turtle.getItemCount(16)
        turtle.suck()
  end

  slotLoop = nonSeamBlocks + 1
  -- Have now picked up all the items that we can. If we have also picked up some
  -- additional fuel in some of the other slots, then drop it again
  while (slotLoop <= lastEmptySlot) do
        -- Drop any items found in this slot
        turtle.select(slotLoop)
        turtle.drop()
        slotLoop = slotLoop + 1
  end

  -- Select the 1st slot because sometimes when leaving the 15th or 16th slots selected it can result
  -- in that slot being immediately filled (resulting in the turtle returning to base again too soon)
  turtle.select(1)

  -- If required, move back to the point that we were mining at before returning to the start
  if (returnBackToMiningPoint == true) then
        -- Return to the point that we were at so that quarrying may resume
        -- Move back to the correct Z position
        writeMessage("Stored Z: "..storedZ..", currZ: "..currZ, messageLevel.DEBUG)
        if (storedZ > currZ) then
          writeMessage("Orienting forward", messageLevel.DEBUG)
          writeMessage("Moving in z direction", messageLevel.DEBUG)
          turtleSetOrientation(direction.FORWARD)
          while (storedZ > currZ) do
                turtleForward()
          end
        elseif (storedZ < currZ) then
          -- This should never happen
          writeMessage("Stored z is less than current z in returnToStartAndUnload", messageLevel.ERROR)
        end

        -- Move back to the correct X position
        if (storedX > currX) then
          writeMessage("Stored X: "..storedX..", currX: "..currX, messageLevel.DEBUG)
          writeMessage("Orienting right", messageLevel.DEBUG)
          writeMessage("Moving in x direction", messageLevel.DEBUG)
          turtleSetOrientation(direction.RIGHT)
          while (storedX > currX) do
                turtleForward()
          end
        elseif (storedX < currX) then
          -- This should never happen
          writeMessage("Stored x is less than current x in returnToStartAndUnload", messageLevel.ERROR)
        end

        -- Move back to the correct Y position
        if (storedY < currY) then
          while (storedY < currY) do
                turtleDown()
          end
        elseif (storedY > currY) then
          -- This should never happen
          writeMessage("Stored y is greater than current y in returnToStartAndUnload", messageLevel.ERROR)
        end

        -- Finally, set the correct orientation
        turtleSetOrientation(storedOrient)

        writeMessage("Have returned to the mining point", messageLevel.DEBUG)
  end

  returningToStart = false

end

-- ********************************************************************************** --
-- Empties a chest's contents
-- ********************************************************************************** --
function emptyChest(suckFn)

  local prevInventoryCount = {}
  local inventoryLoop
  local chestEmptied = false

  -- Record the number of items in each of the inventory slots
  for inventoryLoop = 1, 16 do
        prevInventoryCount[inventoryLoop] = turtle.getItemCount(inventoryLoop)
  end

  while (chestEmptied == false) do
        -- Pick up the next item
        suckFn()

        -- Determine the number of items in each of the inventory slots now
        local newInventoryCount = {}
        for inventoryLoop = 1, 16 do
          newInventoryCount[inventoryLoop] = turtle.getItemCount(inventoryLoop)
        end

        -- Now, determine whether there have been any items taken from the chest
        local foundDifferentItemCount = false
        inventoryLoop = 1
        while ((foundDifferentItemCount == false) and (inventoryLoop <= 16)) do
          if (prevInventoryCount[inventoryLoop] ~= newInventoryCount[inventoryLoop]) then
                foundDifferentItemCount = true
          else
                inventoryLoop = inventoryLoop + 1
          end
        end
  
        -- If no items have been found with a different item count, then the chest has been emptied
        chestEmptied = not foundDifferentItemCount

        if (chestEmptied == false) then
          prevInventoryCount = newInventoryCount
          -- Check that there is sufficient inventory space as may have picked up a block
          ensureInventorySpace()
        end
  end

  writeMessage("Finished emptying chest", messageLevel.DEBUG)
end


-- ********************************************************************************** --
-- Generic function to move the Turtle (pushing through any gravel or other
-- things such as mobs that might get in the way).
--
-- The only thing that should stop the turtle moving is bedrock. Where this is
-- found, the function will return after 15 seconds returning false
-- ********************************************************************************** --
function moveTurtle(moveFn, detectFn, digFn, attackFn, compareFn, suckFn, maxDigCount)

  ensureFuel()

  -- If we are looking for chests, then check that this isn't a chest before moving
  if (lookForChests == true) then
        if (isChestBlock(compareFn) == true) then
          -- Have found a chest, empty it before continuing
          emptyChest (suckFn)
        end
  end

  -- Flag to determine whether digging has been tried yet. If it has
  -- then pause briefly before digging again to allow sand or gravel to
  -- drop
  local digCount = 0
  local moveSuccess = moveFn()

  while ((moveSuccess == false) and (digCount < maxDigCount)) do

        -- If there is a block in front, dig it
        if (detectFn() == true) then
          
                -- If we've already tried digging, then pause before digging again to let
                -- any sand or gravel drop
                if(digCount > 0) then
                  sleep(0.4)
                end

                digFn()
                digCount = digCount + 1
        else
           -- Am being stopped from moving by a mob, attack it
           attackFn()
        end

        -- Try the move again
        moveSuccess = moveFn()
  end

  -- Return the move success
  return moveSuccess

end

-- ********************************************************************************** --
-- Move the turtle forward one block (updating the turtle's position)
-- ********************************************************************************** --
function turtleForward()
  local returnVal = moveTurtle(turtle.forward, turtle.detect, turtle.dig, turtle.attack, turtle.compare, turtle.suck, maximumGravelStackSupported)
  if (returnVal == true) then
        -- Update the current co-ordinates
        if (currOrient == direction.FORWARD) then
          currZ = currZ + 1
        elseif (currOrient == direction.LEFT) then
          currX = currX - 1
        elseif (currOrient == direction.BACK) then
          currZ = currZ - 1
        elseif (currOrient == direction.RIGHT) then
          currX = currX + 1
        else
          writeMessage ("Invalid currOrient in turtleForward function", messageLevel.ERROR)
        end

        -- Check that there is sufficient inventory space as may have picked up a block
        ensureInventorySpace()
  end

  return returnVal
end

-- ********************************************************************************** --
-- Move the turtle up one block (updating the turtle's position)
-- ********************************************************************************** --
function turtleUp()
  local returnVal = moveTurtle(turtle.up, turtle.detectUp, turtle.digUp, turtle.attackUp, turtle.compareUp, turtle.suckUp, maximumGravelStackSupported)
  if (returnVal == true) then
        currY = currY + 1

        -- Check that there is sufficient inventory space as may have picked up a block
        ensureInventorySpace()
  end
  return returnVal
end

-- ********************************************************************************** --
-- Move the turtle down one block (updating the turtle's position)
-- ********************************************************************************** --
function turtleDown()
  local returnVal

  -- Because the turtle is digging down, can fail fast (only allow 1 dig attempt).
  returnVal = moveTurtle(turtle.down, turtle.detectDown, turtle.digDown, turtle.attackDown, turtle.compareDown, turtle.suckDown, 1)
  if (returnVal == true) then
        currY = currY - 1

        -- Check that there is sufficient inventory space as may have picked up a block
        ensureInventorySpace()
  end
  return returnVal
end

-- ********************************************************************************** --
-- Move the turtle back one block (updating the turtle's position)
-- ********************************************************************************** --
function turtleBack()
  -- First try to move back using the standard function
  local returnVal = turtle.back()

  -- Moving back didn't work (might be a block or a mob in the way). Turn round and move
  -- forward instead (whereby anything in the way can be cleared)
  if(returnVal == false) then
        turtle.turnRight()
        turtle.turnRight()
        returnVal = turtleForward()
        turtle.turnRight()
        turtle.turnRight()
  end

  if (returnVal == true) then
        -- Update the current co-ordinates
        if (currOrient == direction.FORWARD) then
          currZ = currZ - 1
        elseif (currOrient == direction.LEFT) then
          currX = currX + 1
        elseif (currOrient == direction.BACK) then
          currZ = currZ + 1
        elseif (currOrient == direction.RIGHT) then
          currX = currX - 1
        else
          writeMessage ("Invalid currOrient in turtleBack function", messageLevel.ERROR)
        end

        -- Check that there is sufficient inventory space as may have picked up a block
        ensureInventorySpace()
  end
  
  return returnVal
end

-- ********************************************************************************** --
-- Turns the turtle (updating the current orientation at the same time)
-- ********************************************************************************** --
function turtleTurn(turnDir)

  if (turnDir == direction.LEFT) then
        if (currOrient == direction.FORWARD) then
          currOrient = direction.LEFT
          turtle.turnLeft()
        elseif (currOrient == direction.LEFT) then
          currOrient = direction.BACK
          turtle.turnLeft()
        elseif (currOrient == direction.BACK) then
          currOrient = direction.RIGHT
          turtle.turnLeft()
        elseif (currOrient == direction.RIGHT) then
          currOrient = direction.FORWARD
          turtle.turnLeft()
        else
          writeMessage ("Invalid currOrient in turtleTurn function", messageLevel.ERROR)
        end
  elseif (turnDir == direction.RIGHT) then
        if (currOrient == direction.FORWARD) then
          currOrient = direction.RIGHT
          turtle.turnRight()
        elseif (currOrient == direction.LEFT) then
          currOrient = direction.FORWARD
          turtle.turnRight()
        elseif (currOrient == direction.BACK) then
          currOrient = direction.LEFT
          turtle.turnRight()
        elseif (currOrient == direction.RIGHT) then
          currOrient = direction.BACK
          turtle.turnRight()
        else
          writeMessage ("Invalid currOrient in turtleTurn function", messageLevel.ERROR)
        end
  else
        writeMessage ("Invalid turnDir in turtleTurn function", messageLevel.ERROR)
  end
end

-- ********************************************************************************** --
-- Sets the turtle to a specific orientation, irrespective of its current orientation
-- ********************************************************************************** --
function turtleSetOrientation(newOrient)

  if (currOrient ~= newOrient) then
        if (currOrient == direction.FORWARD) then
          if (newOrient == direction.RIGHT) then
                turtle.turnRight()
                currOrient = newOrient
          elseif (newOrient == direction.BACK) then
                turtle.turnRight()
                turtle.turnRight()
                currOrient = newOrient
          elseif (newOrient == direction.LEFT) then
                turtle.turnLeft()
                currOrient = newOrient
          else
                writeMessage ("Invalid newOrient in turtleSetOrientation function", messageLevel.ERROR)
          end
        elseif (currOrient == direction.RIGHT) then
          if (newOrient == direction.BACK) then
                turtle.turnRight()
                currOrient = newOrient
          elseif (newOrient == direction.LEFT) then
                turtle.turnRight()
                turtle.turnRight()
                currOrient = newOrient
          elseif (newOrient == direction.FORWARD) then
                turtle.turnLeft()
                currOrient = newOrient
          else
                writeMessage ("Invalid newOrient in turtleSetOrientation function", messageLevel.ERROR)
          end
        elseif (currOrient == direction.BACK) then
          if (newOrient == direction.LEFT) then
                turtle.turnRight()
                currOrient = newOrient
          elseif (newOrient == direction.FORWARD) then
                turtle.turnRight()
                turtle.turnRight()
                currOrient = newOrient
          elseif (newOrient == direction.RIGHT) then
                turtle.turnLeft()
                currOrient = newOrient
          else
                writeMessage ("Invalid newOrient in turtleSetOrientation function", messageLevel.ERROR)
          end
        elseif (currOrient == direction.LEFT) then
          if (newOrient == direction.FORWARD) then
                turtle.turnRight()
                currOrient = newOrient
          elseif (newOrient == direction.RIGHT) then
                turtle.turnRight()
                turtle.turnRight()
                currOrient = newOrient
          elseif (newOrient == direction.BACK) then
                turtle.turnLeft()
                currOrient = newOrient
          else
                writeMessage ("Invalid newOrient in turtleSetOrientation function", messageLevel.ERROR)
          end
        else
          writeMessage ("Invalid currOrient in turtleTurn function", messageLevel.ERROR)
        end
  end
end

-- ********************************************************************************** --
-- Determines if a particular block is considered a noise block or not. A noise
-- block is one that is a standard block in the game (stone, dirt, gravel etc.) and
-- is one to ignore when a seam is being dug out. Function works by comparing the block
-- in question against a set of blocks in the turtle's inventory which are known not to
-- be noise blocks. The first parameter is the number of slots containing noise blocks
-- (these must be at the start of the turtle's inventory), and the second param is the
-- function to use to compare the block for a noise block
-- ********************************************************************************** --
function isNoiseBlock(detectFn, compareFn)

  -- Consider air to be a noise block
  local returnVal = not detectFn()
  local seamLoop = 1

  while((returnVal == false) and (seamLoop <= nonSeamBlocks)) do
        turtle.select(seamLoop)
        returnVal = compareFn()
        seamLoop = seamLoop + 1
  end

  -- Return the calculated value
  return returnVal

end

-- ********************************************************************************** --
-- Determines if a particular block is a chest. Returns false if it is not a chest
-- or chests are not being detected
-- ********************************************************************************** --
function isChestBlock(compareFn)

  -- Check the block in the appropriate direction to see whether it is a chest. Only
  -- do this if we are looking for chests
  local returnVal = false
  if (lookForChests == true) then
        turtle.select(15)
        returnVal = compareFn()
  end

  -- Return the calculated value
  return returnVal

end

-- ********************************************************************************** --
-- Function to calculate the number of non seam blocks in the turtle's inventory. This
-- is all of the blocks at the start of the inventory (before the first empty slot is
-- found
-- ********************************************************************************** --
function determineNonSeamBlocksCount()
  -- Determine the location of the first empty inventory slot. All items before this represent
  -- noise items.
  local foundFirstBlankInventorySlot = false
  nonSeamBlocks = 1
  while ((nonSeamBlocks < 16) and (foundFirstBlankInventorySlot == false)) do
        if (turtle.getItemCount(nonSeamBlocks) > 0) then
          nonSeamBlocks = nonSeamBlocks + 1
        else
          foundFirstBlankInventorySlot = true
        end
  end
  nonSeamBlocks = nonSeamBlocks - 1

  -- Determine whether a chest was provided, and hence whether we should support
  -- looking for chests
  if (turtle.getItemCount(15) > 0) then
        lookForChests = true
        lastEmptySlot = 14
        writeMessage("Looking for chests...", messageLevel.DEBUG)
  else
        lastEmptySlot = 15
        writeMessage("Ignoring chests...", messageLevel.DEBUG)
  end
end

-- ********************************************************************************** --
-- Creates a quarry mining out only ores and leaving behind any noise blocks
-- ********************************************************************************** --
function createQuarry()

  -- Determine the starting layer. The turtle mines in layers of 3, and the bottom layer
  -- is the layer directly above bedrock.
  --
  -- The actual layer that the turtle operates in is the middle of these three layers,
  -- so determine the top layer
  local firstMiningLayer = startHeight + ((bottomLayer - startHeight - 2) % 3) - 1

  -- If the top layer is up, then ignore it and move to the next layer
  if (firstMiningLayer > currY) then
        firstMiningLayer = firstMiningLayer - 3
  end

  local miningLoop
  local firstTimeThru = true
  local onNearSideOfQuarry = true
  local diggingAway = true

  -- Loop over each mining row
  for miningLoop = firstMiningLayer, bottomLayer, -3 do
        writeMessage("Mining Layer: "..miningLoop, messageLevel.INFO)

        -- Move to the correct level to start mining
        if (currY > miningLoop) then
          while (currY > miningLoop) do
                turtleDown()
          end
        end

        -- Move turtle into the correct orientation to start mining
        if (firstTimeThru == true) then
          turtleTurn(direction.RIGHT)
          firstTimeThru = false
        else
          turtleTurn(direction.LEFT)
          turtleTurn(direction.LEFT)
        end

        local firstRow = true
        local mineRows
        for mineRows = 1, quarryWidth do
          -- If this is not the first row, then get into position to mine the next row
          if (firstRow == true) then
                firstRow = false
          else
                -- Move into position for mining the next row
                if (onNearSideOfQuarry == diggingAway) then
                  turtleTurn(direction.RIGHT)
                else
                  turtleTurn(direction.LEFT)
                end

                turtleForward()
                if (isChestBlock(turtle.compareUp) == true) then
                  -- There is a chest block above. Move back and approach
                  -- from the side to ensure that we don't need to return to
                  -- start through the chest itself (potentially losing items)
                  turtleBack()
                  turtleUp()
                  emptyChest(turtle.suck)
                  turtleDown()
                  turtleForward()
                end

                -- Move into final position for mining the next row
                if (onNearSideOfQuarry == diggingAway) then
                  turtleTurn(direction.RIGHT)
                else
                  turtleTurn(direction.LEFT)
                end
          end

          -- Dig to the other side of the quarry
          local blocksMined
          for blocksMined = 0, (quarryWidth - 1) do
                -- Move forward and check for ores
                if(blocksMined > 0) then
                  -- Only move forward if this is not the first space
                  turtleForward()
                end
                
                -- Check upwards for a chest block if this is not the first block of the
                -- row (in which case it will have already been checked)
                if(blocksMined > 0) then
                  if (isChestBlock(turtle.compareUp) == true) then
                        -- There is a chest block above. Move back and approach
                        -- from the side to ensure that we don't need to return to
                        -- start through the chest itself (potentially losing items)
                        turtleBack()
                        turtleUp()
                        emptyChest(turtle.suck)
                        turtleDown()
                        turtleForward()
                  end
                end
          
                if (isNoiseBlock(turtle.detectUp, turtle.compareUp) == false) then
                  turtle.digUp()
                  ensureInventorySpace()
                end

                -- Check down, if this is the bedrock layer, use an alternate approach.
                -- If this is not the bedrock layer, then just check down
                if (miningLoop == bottomLayer) then
                  -- Just above bedrock layer, dig down until can't dig any lower, and then
                  -- come back up. This replicates how the quarry functions
                  local moveDownSuccess = turtleDown()
                  while (moveDownSuccess == true) do
                        moveDownSuccess = turtleDown()
                  end

                  -- Have now hit bedrock, move back to the mining layer
                  writeMessage("Moving back to mining layer", messageLevel.DEBUG)
                  writeMessage("currY: "..currY..", bottomLayer: "..bottomLayer, messageLevel.DEBUG)
                  while (currY < bottomLayer) do
                        turtleUp()
                  end
                else
                  -- Check the block down for being a chest
                  if (isChestBlock(turtle.compareDown) == true) then
                        emptyChest(turtle.suckDown)
                  end

                  -- Check the block down and mine if necessary
                  if (isNoiseBlock(turtle.detectDown, turtle.compareDown) == false) then
                        turtle.digDown()
                        ensureInventorySpace()
                  end
                end
          end

          -- Am now at the other side of the quarry
          onNearSideOfQuarry = not onNearSideOfQuarry
        end

        -- If we were digging away from the starting point, will be digging
        -- back towards it on the next layer
        diggingAway = not diggingAway
  end

  -- Return to the start
  returnToStartAndUnload(false)

  -- Face forward
  turtleSetOrientation(direction.FORWARD)
end

-- ********************************************************************************** --
-- Main Function                                                                                
-- ********************************************************************************** --
-- Process the input arguments - storing them to global variables
local args = { ... }
local paramsOK = true
turtleId = os.getComputerLabel()
rednet.open("right")
if (#args == 1) then
  quarryWidth = tonumber(args[1])
  local x, y, z = gps.locate(5)
  startHeight = y
  if (startHeight == nil) then
        writeMessage("Can't locate GPS", messageLevel.FATAL)
        paramsOK = false
  end
elseif (#args == 2) then
  quarryWidth = tonumber(args[1])
  startHeight = tonumber(args[2])
else
  writeMessage("Usage: OreQuarry <diameter> <turtleY>", messageLevel.FATAL)
  paramsOK = false
end
if (paramsOK == true) then
  if ((startHeight < 6) or (startHeight > 128)) then
        writeMessage("turtleY must be between 6 and 128", messageLevel.FATAL)
        paramsOK = false
  end

  if ((quarryWidth < 2) or (quarryWidth > 64)) then
        writeMessage("diameter must be between 2 and 64", messageLevel.FATAL)
        paramsOK = false
  end
end

if (paramsOK == true) then
  writeMessage("---------------------------------", messageLevel.INFO)
  writeMessage("** Ore Quarry v0.2 by AustinKK **", messageLevel.INFO)
  writeMessage("---------------------------------", messageLevel.INFO)

  -- Set the turtle's starting position
  currX = 0
  currY = startHeight
  currZ = 0
  currOrient = direction.FORWARD

  -- Calculate which blocks in the inventory signify noise blocks
  determineNonSeamBlocksCount()

  if ((nonSeamBlocks == 0) or (nonSeamBlocks == 15)) then
        writeMessage("No noise blocks have been been added. Please place blocks that the turtle should not mine (e.g. Stone, Dirt, Gravel etc.) in the first few slots of the turtle\'s inventory. The first empty slot signifies the end of the noise blocks.", messageLevel.FATAL)
  else
        -- Create a Quary
        createQuarry()
  end
end