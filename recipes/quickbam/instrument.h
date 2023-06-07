#ifndef YICPPLIB_INSTRUMENT_H
#define YICPPLIB_INSTRUMENT_H

#include <chrono>
#include <map>
#include <vector>
#include <iostream>
#include <numeric>
#include <memory>
#include <mutex>

using namespace std::chrono;

namespace YiCppLib {

    template<typename ResT>
    class Instrument {
        public:
            static std::unique_ptr<Instrument>& instance() {
                static std::unique_ptr<Instrument> _instance = nullptr;
                static std::mutex singleton_mutex;
                singleton_mutex.lock();
                if(_instance.get() == nullptr) 
                    _instance.reset(new Instrument());
                singleton_mutex.unlock();
                return _instance;
            }

            time_point<high_resolution_clock> get_clock() {
                return high_resolution_clock::now();
            }

            void add_measurement(const std::string& name, time_point<high_resolution_clock> start) {
                time_point<high_resolution_clock> end = high_resolution_clock::now();
                auto diff = end - start;
                auto d = duration_cast<ResT>(end - start);

                measurement_lock.lock();
                if (measurements.find(name) == measurements.end()) {
                    measurement_names.push_back(name);
                    measurements[name] = std::vector<long>();
                }

                measurements[name].push_back(d.count());
                measurement_lock.unlock();
            }

            ~Instrument() {
                std::cerr<<"INSTRUMENT REPORT:"<<std::endl;
                for(auto& name : measurement_names) {
                    std::cerr<<name<<": ";
                    auto& m = measurements[name]; 
                    auto sum = std::accumulate(m.cbegin(), m.cend(), 0);
                    auto ave = (double)(sum) / m.size();
                    std::cerr<<sum<<" (tot); "<<ave<<" (ave) "<<m.size()<<" (siz)"<<std::endl;
                }
            }

        protected:
            //static Instrument* _instance;
            Instrument() {}
            std::mutex measurement_lock;
            std::vector<std::string> measurement_names;
            std::map<std::string, std::vector<long>> measurements;
    };
}


#endif
