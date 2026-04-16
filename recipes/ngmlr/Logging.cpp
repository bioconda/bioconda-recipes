/**
 * Contact: philipp.rescheneder@gmail.com
 */

#include "Log.h"

#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>
#include <vector>
#include <string>
#include <ctime>

#include "PlatformSpecifics.h"
#include "NGMThreads.h"
#include "zlib.h"

namespace __Log {
_Log * pInstance = 0;
NGMMutex mutex;
NGMOnceControl once_control = NGM_ONCE_INIT;

int rwd;

int warningCount = 0;

void Init() {
	pInstance = new _Log();
	InitConsole();

	NGMInitMutex(&mutex);
}

int filterlvl = 0;
int logLvl;
bool color = false;
bool init = false;
char preBuffer[1024];
bool preInit = true;
bool logToFile = false;
std::vector<std::string> & msgLog() {
	static std::vector<std::string> * res = new std::vector<std::string>();
	return *res;
}

gzFile fp = 0;

char const * lvlStr[] = { "", "[WARNING]", "[ERROR]", "" };

void LogToFile(int lvl, char const * const title, char const * const s, va_list args) {
	if (!logToFile && !preInit)
		return;

	int written = 0;

	if (title != 0)
		written += sprintf(preBuffer, "%s[%s] ", lvlStr[lvl], title);
	else
		written += sprintf(preBuffer, "%d\t", lvl);

	vsprintf(preBuffer + written, s, args);

	if (preInit)
		msgLog().push_back(std::string(preBuffer));

	if (logToFile) {
//		gzprintf(fp, "%s\n", preBuffer);
		printf("%s\n", preBuffer);
		//gzflush(fp);
	}
}

// rewind lines
inline void rwl() {
	for (int i = 0; i < rwd; ++i)
		fprintf(stderr, "\033[A\033[2K");
	rwd = 0;
}

void LogToConsole(bool color, int lvl, char const * const title, char const * const s, va_list args) {
	if (lvl < filterlvl)
		return;

	bool progress = lvl == 99;
	if (progress)
		lvl = 0;
	rwl();

//	if (title != 0) {
//		if (lvl > 0 && color)
//			SetConsoleColor((ConsoleColor) (MessageTitle + (lvl * 2)));
//		fprintf(stderr, "[%s] ", title);
//	}

	if (color)
		SetConsoleColor((ConsoleColor) (Message + (lvl * 2)));
//	if (args != 0)
//		vfprintf(stderr, s, args);
//	else
		fprintf(stderr, "%s", s);
	if (color)
		ResetConsoleColor();
	fprintf(stderr, "\n");
	if (progress) {
		rwd = 1;
	}
}

}

using namespace __Log;

std::string add_timestamp(std::string str) {
	std::string::size_type pos = str.find("%s");
	if (pos != std::string::npos) {
		//char months[] = "Jan\0Feb\0Mar\0Apr\0May\0Jun\0Jul\0Aug\0Sep\0Oct\0Nov\0Dec\0";
		const time_t t = time(0);
		tm * tm = localtime(&t);

		char timestamp[20];
		sprintf(timestamp, "%4i-%02i-%02i_%02i-%02i-%02i", tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday, tm->tm_hour, tm->tm_min,
				tm->tm_sec); //months+m*4

		return str.replace(pos, 2, timestamp);
	}
	return str;
}

void _Log::Init(char const * logFile, int pLogLvl) {
	logLvl = pLogLvl;
	init = true;
	NGMLock(&__Log::mutex);

	try {
		if (logFile != 0) {

			//fp = gzopen(logFile, "w");
			//if (fp != 0) {
				for (uint i = 0; i < msgLog().size(); ++i) {
					//gzprintf(fp, "%s\n", msgLog()[i].c_str());
					printf("%s\n", msgLog()[i].c_str());
				}
				msgLog().clear();
				logToFile = true;
			//} else {
				//LogToConsole(2, "LOG", "Unable to open logfile, logging to file disabled.", 0);
				//Log.Error("Unable to open logfile, logging to file disabled.");
				//logToFile = false;
			//}

			preInit = false;

		}
	} catch (...) {
		NGMUnlock(&__Log::mutex);
		init = false;
		throw;
	}

	NGMUnlock(&__Log::mutex);
	init = false;
}

_Log const & _Log::Instance() {
	NGMOnce(&__Log::once_control, __Log::Init);

	return *__Log::pInstance;
}

void _Log::_Debug(int lvl, char const * const title, char const * const s, ...) const {
	va_list args;

	if (init) {
		fprintf(stderr, "Log Init active - Message blocked.\n");
		fprintf(stderr, "(lvl = %i) (t)%s %s\n", lvl, title, s);
		return;
	}
	NGMLock(&__Log::mutex);

	if (logLvl & lvl) {
		va_start(args, s);
		LogToFile(lvl, 0, s, args);
		va_end(args);
	}

	NGMUnlock(&__Log::mutex);
}
//LogToFile(int lvl, char const * const title, char const * const s, va_list args)
void _Log::_Message(int lvl, char const * const title, char const * const s, ...) const {
	va_list args;

	if (init) {
		fprintf(stderr, "Log Init active - Message blocked.\n");
		fprintf(stderr, "(lvl = %i) (t)%s %s\n", lvl, title, s);
		return;
	}
	NGMLock(&__Log::mutex);
	va_start(args, s);
	LogToConsole(color, lvl, title, s, args);
	va_end(args);

	/*// File Logging disabled (use "tee")
	 va_start(args, s);
	 LogToFile(lvl, title, s, args);
	 va_end(args);
	 */
	NGMUnlock(&__Log::mutex);

	bool terminate = false;

	if (lvl == 1) {
		warningCount += 1;
		if (warningCount > 100) {
			fprintf(stderr, "Max number of warnings reached!\nPlease report this issue on http://github.com/Cibiv/NextGenMap/issues!\n");
			terminate = true;
		}
	}
	if (lvl == 2) {
		fprintf(stderr, "Terminating\n");
		terminate = true;
	}

	if(terminate) {
		ResetConsole();
		if (fp != 0) {
			gzclose(fp);
		}
		exit(1);
	}

}

void _Log::Cleanup() {
	if (fp != 0) {
		gzclose(fp);
	}
	delete pInstance;
}

_Log::_Log() {

}
_Log::~_Log() {
}

void _Log::setColor(bool const pColor) {
	__Log::color = pColor;
}

void _Log::FilterLevel(int const lvl) {
	__Log::filterlvl = lvl;
}

