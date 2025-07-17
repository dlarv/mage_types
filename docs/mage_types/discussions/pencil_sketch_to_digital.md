1. Boost contrast
2. Colors/Poserize (lvl 2 or 3)
	1. If parts of sketch disappear (are turned into the wrong color):
	2. Posterize lvl 3
	3. Identify majority color inside problem area
	4. Identify target color (color that is not disappearing)
	5. Use Colors/Map/Color Exchange to change problem color to target 
		1. You might have to mess with the threshold values
		2. If that doesn't work, ensure nothing is selected
		3. If that doesn't work:
			1. Duplicate layer
			2. Select new layer
			3. Merge down
			4. Idrk why this works, but I think it has to do with the "Active Filters" that can be found in the layer attributes. Doing this clears out this list, without deleting changes
	6. Repeat steps 3-5 until lines are good enough
3. If on grid paper, use Colors/Map/Color Exchange to remove lines
	1. See steps 2.5.* for troubleshooting steps
4. Apply Filters/Blur/Gaussian Blur
5. Adjust Colors/Brightness-Contrast... to make lines thicker
6. Use Shift+O (Tools/Selection Tools/By Color Select) to select white background
7. Use Shift+X (cut) to remove white background
	1. If background turns into a solid color, remember to add an Alpha Channel to the layer