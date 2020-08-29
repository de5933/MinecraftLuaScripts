local args = {...}

local file = args[1]

local printer = peripheral.wrap('bottom'
local ready = printer.newPage()

if printer.getPaperLevel() == 0 then
	error('There is no paper in the printer!')
end

if printer.getInkLevel() == 0 then
	error('There is no ink in the printer!')
end

if ready then
	local src = fs.open(file, 'r')
	local width, height = printer.getPageSize()
	local txt = src.readLine()
	local row = 0

	while txt do
		if row > height then
			printer.endPage()
			printer.newPage()
			row = 0
			printer.write(txt)
		end
		row = row + 1
		txt = src.readLine()
	end

	printer.write(src.readLine())
	printer.endPage()
else
	error('Could not create a page. Is there any paper and ink in the printer?')
end