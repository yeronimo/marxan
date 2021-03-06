#' @include RcppExports.R marxan-internal.R
NULL

#' Test if GDAL is installed on computer
#'
#' This function tests if GDAL is installed on the computer.
#' If not, download it here: \url{http://download.osgeo.org/gdal}.
#'
#' @return "logical" is GDAL installed?
#' @seealso \code{\link[gdalUtils]{gdal_setInstallation}}.
#' @export
#' @examples
#' is.gdalInstalled()
is.gdalInstalled<-function() {
	suppressWarnings(findGdalInstallationPaths())
	return(!is.null(getOption("gdalUtils_gdalPath")))
}


#' Rasterize polygon data using GDAL
#'
#' This function converts a "SpatialPolygonsDataFrame" to a "RasterLayer" using GDAL.
#' It is expected to be faster than \code{\link[raster]{rasterize}} for large datasets.
#' However, it will be significantly slower for small datasets because the data will need to be written and read from disk.
#' @param x "SpatialPolygonsDataFrame" object.
#' @param y "RasterLayer" with dimensions, extent, and resolution to be used as a template for new raster.
#' @param field "character" column name with values to burn into the output raster. If not supplied, default behaviour is to burn polygon indices into the "RasterLayer".
#' @export
#' @return "RasterLayer" object.
#' @seealso \code{\link[raster]{rasterize}}, \code{\link{is.gdalInstalled}}.
#' @examples
#' data(species,planningunits)
#' x<-rasterize.gdal(planningunits[1:5,],species[[1]])
setGeneric('rasterize.gdal', function(x,y, ...) standardGeneric('rasterize.gdal'))
setMethod(
	'rasterize.gdal',
	signature(x="SpatialPolygonsDataFrame", y="RasterLayer"),
	function(x, y, field=NULL) {
		if (is.null(field)) {
			x@data$id<-seq_len(nrow(x@data))
			field<-'id'
		}
		if (!field %in% names(x@data))
			stop(paste0("x@data does not have a field called ",field, "."))
		writeOGR(x, tempdir(), 'polys', driver='ESRI Shapefile', overwrite=TRUE)
		writeRaster(setValues(y, NA), file.path(tempdir(), 'rast.tif'), NAflag=-9999, overwrite=TRUE)
		return(gdal_rasterize(file.path(tempdir(), 'polys.shp'), file.path(tempdir(), 'rast.tif'), l="polys", a=field, output_Raster=TRUE)[[1]])
	}
)

#' Test if Marxan is installed on computer
#'
#' This function determines if Marxan is installed on the computer, and will update \code{\link[base]{options}}.
#'
#' @return "logical" Is it installed?
#' @seealso \code{\link[base]{options}}, \code{\link{findMarxanExecutablePath}}.
#' @export
#' @examples
#' options()$marxanExecutablePath
#' is.marxanInstalled()

is.marxanInstalled<-function(verbose=FALSE) {
	if (!verbose)
		return(!is.null(options()$marxanExecutablePath) & file.exists(options()$marxanExecutablePath))
	if (!is.null(options()$marxanExecutablePath)) {
		if (file.exists(options()$marxanExecutablePath))
			cat('marxan R package successfully installed\n')
	} else {
		cat('marxan R package cannot find Marxan executable files.\n')
	}
	return(invisible())
}

#' Find Marxan executable suitable for computer
#'
#' This function checks the computer's specifications and sets options('marxanExecutablePath') accordingly.
#' Marxan executables can be downloaded from \url{http://www.uq.edu.au/marxan/marxan-software}, and installed by unzipping the files contents, and copying them into the /bin folder in this package's installation directory. 
#' If a suitable executable cannot be found, this function will fail and provide information.
#'
#' @seealso \code{\link{is.marxanInstalled}}.
#' @return "logical" Is Marxan installed?
#' @export
#' @examples
#' # marxan executable files should be copied to this directory
#' system.file("bin", package="marxan")
#' # look for Marxan
#' \donttest{
#' findMarxanExecutablePath()
#' }
#' # was Marxan found?
#' is.marxanInstalled()
findMarxanExecutablePath<-function() {
	# if path already set then return it
	if(!is.null(options()$marxanExecutablePath))
		return(options()$marxanExecutablePath)
	# if path not set then set it
	if (.Platform$OS.type=="windows") {
		if (.Platform$r_arch=="x64") {
			path=list.files(system.file("bin", package="marxan"), "^Marxan.*x64.exe$",full.names=TRUE)
		} else if (.Platform$r_arch=="i386") {
			path=system.file('bin/Marxan.exe', package="marxan")
		} else {
			stop('Marxan will only run in 64bit or 32bit Windows environments.')
		}
	} else {
		if (.Platform$OS.type=="unix") {
			if (Sys.info()[["sysname"]]=="Darwin") {
				if (Sys.info()[["machine"]]=="x86_64") {
					path=list.files(system.file("bin", package="marxan"), "^MarOpt.*Mac64",full.names=TRUE)
				} else if (Sys.info()[["machine"]]=="i686") {
					path=list.files(system.file("bin", package="marxan"), "^MarOpt.*Mac32",full.names=TRUE)
				}
			} else {
				if (Sys.info()[["machine"]]=="x86_64") {
					path=list.files(system.file("bin", package="marxan"), "^MarOpt.*Linux64",full.names=TRUE)
				} else if (Sys.info()[["machine"]]=="i686") {
					path=list.files(system.file("bin", package="marxan"), "^MarOpt.*Linux32",full.names=TRUE)
				}
			}
		} else {
			stop("Only Windows, Mac OSX, and Linux systems are supported.")
		}
	}
	# check that path is valid
	if (length(path)!=1 || !file.exists(path))
		stop(paste0("Marxan executable files not found.\nDownload marxan from ",marxanURL,",\nand copy the files into: ", system.file("bin", package="marxan")))
	options(marxanExecutablePath=path)
}



