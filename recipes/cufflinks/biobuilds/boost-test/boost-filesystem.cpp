#include <boost/filesystem.hpp>

int main() {
  boost::filesystem::path p("/tmp/cufflinks-patch/data/analysis");
  boost::filesystem::create_directories(p);

  return 0;
}
