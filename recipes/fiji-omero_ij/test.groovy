import omero.gateway.LoginCredentials
import omero.gateway.Gateway
import omero.gateway.SecurityContext
import omero.gateway.facility.BrowseFacility
import omero.gateway.model.ExperimenterData
import omero.gateway.model.ImageData
import omero.gateway.model.PixelsData
import omero.log.Logger
import omero.log.SimpleLogger

userName = "public"
password = "public"
host = "idr.openmicroscopy.org"

LoginCredentials cred = new LoginCredentials(userName, password, host)
Logger simpleLogger = new SimpleLogger()

Gateway gateway = new Gateway(simpleLogger)
ExperimenterData user = gateway.connect(cred)
println user
SecurityContext ctx = new SecurityContext(user.getGroupId())
println ctx
BrowseFacility browse = gateway.getFacility(BrowseFacility.class);
ImageData image = browse.getImage(ctx, 1229801)
PixelsData pixels = image.getDefaultPixels()
assert pixels.getSizeZ() == 16 // The number of z-sections.
assert pixels.getSizeC() == 2 // The number of channels.

gateway.disconnect()

return