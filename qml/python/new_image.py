import pyotherside
from PIL import Image


def create_image(path, width, height, color):
    output_img = Image.new("RGBA", (int(width), int(height)), color=color)
    output_img.save(path)
    
    pyotherside.send('fileIsSaved', path)
    pyotherside.send('exchangeImage', path)
    pyotherside.send('finishedSavingRenaming', path)
    
    output_img.close()
