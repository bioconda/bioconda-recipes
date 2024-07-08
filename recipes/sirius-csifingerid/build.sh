packageName=$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM
outdir=$PREFIX/share/$packageName

./gradlew :sirius_dist:sirius_gui_dist:installSiriusDist \
  -P "build.sirius.location.lib=\$CONDA_PREFIX/share/$PKG_NAME-$PKG_VERSION-$PKG_BUILDNUM/app" \
  -P "build.sirius.starter.jdk.include=false" \
  -P "build.sirius.native.cbc.exclude=true" \
  -P "build.sirius.native.openjfx.exclude=false" \
  -P "build.sirius.platform=$target_platform"

mkdir -p "${outdir:?}"
mkdir -p "${PREFIX:?}/bin"
cp -rp ./sirius_dist/$siriusDistDir/build/install/$siriusDistName/* "${outdir:?}/"
rm -r "${outdir:?}/bin"
cp -rp ./sirius_dist/$siriusDistDir/build/install/$siriusDistName/bin/* "${PREFIX:?}/bin/"
