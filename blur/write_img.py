from PIL import Image
import numpy
im = Image.open('new_image.jpg', 'r')
img = im.load()
width, height = im.size
pixel_values = list(im.getdata())
pixel_values = numpy.array(pixel_values).reshape((width, height, 3))
f = open("new_image.txt","r")
for i in range(height):
    for j in range(width):
        r = int(f.readline())
        g = int(f.readline())
        b = int(f.readline())
        im.putpixel((i,j), (r,g,b))

im.save("new_image.jpg")
f.close()