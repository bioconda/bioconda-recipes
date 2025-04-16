echo "
#include <Carna/Carna.h>

int main()
{
}
" > test.cpp

${CXX} test.cpp -I${CONDA_PREFIX}/include -L${CONDA_PREFIX}/lib -lGLU -lCarna-3.3.3  # TODO: replace by {{ version }}
