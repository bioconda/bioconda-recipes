#The current recipe is the modified version of
#the recipe which  was developed by Aaron Meurer
#and was obtained from https://anaconda.org/asmeurer/pandoc/files.

# This might be different in general. You can find the general location by
# running ghci and running
#   :m System.Directory
#   getAppUserDataDirectory "cabal"
# I couldn't figure out how to run this dynamically. ghci doesn't seem to have
# a -c switch like python.
#export PATH="$HOME/.cabal/bin:$PATH"
cabal install alex happy
cabal install --only-dependencies
cabal install hsb2hs  # a required build tool

#the installation of citeproc-hs encountered the compilation errors
#which occured in both UBUNTU (14.04) and CENTOS (6.7).
#cabal install --flags="embed_data_files" citeproc-hs

cabal configure --flags="embed_data_files"
cabal build
mkdir -p $PREFIX/bin
cp $SRC_DIR/dist/build/pandoc/pandoc $PREFIX/bin/pandoc
