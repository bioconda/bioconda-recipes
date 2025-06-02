import fr.igred.omero.Client
import fr.igred.omero.repository.ImageWrapper
import fr.igred.omero.repository.PixelsWrapper

userName = "public"
password = "public"
host = "idr.openmicroscopy.org"

Client client = new Client()
client.connect(host, 4064, userName, password.toCharArray())

ImageWrapper image = client.getImage(1229801)
PixelsWrapper pixels = image.getPixels()
assert pixels.getSizeZ() == 16 // The number of z-sections.
assert pixels.getSizeC() == 2 // The number of channels.

client.disconnect()

return