echo "now you've installed PCAone successfully!
however, you still need to do an addtional post step to update LD_LIBRARY_PATH in your .bashrc or .zshrc as follows:"
echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$PREFIX/lib\" >> ~/.bashrc"
echo "export LD_LIBRARY_PATH=\"\$LD_LIBRARY_PATH:$PREFIX/lib\" >> ~/.zshrc"
