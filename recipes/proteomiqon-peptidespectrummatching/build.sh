
#!/bin/bash
PREFIX=$(echo "${PREFIX}" | tr '\\' '/')
DOTNET_ROOT="${PREFIX}/lib/dotnet"
TOOL_ROOT=$DOTNET_ROOT/tools/PeptideSpectrumMatching

mkdir -p $PREFIX/bin $TOOL_ROOT
cp -r $SRC_DIR/* $TOOL_ROOT
cp "$RECIPE_DIR/proteomiqon-peptidespectrummatching.sh" "$PREFIX/bin/proteomiqon-peptidespectrummatching"
chmod +x "$PREFIX/bin/proteomiqon-peptidespectrummatching"
