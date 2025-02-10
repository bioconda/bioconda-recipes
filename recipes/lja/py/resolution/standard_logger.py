import logging
import sys


def get_logger(filename,
               logger_name='centroFlye',
               level=logging.INFO,
               filemode='a',
               stdout=True):
    logger = logging.getLogger(logger_name)
    logger.setLevel(level)

    # create the logging file handler
    fh = logging.FileHandler(filename, mode=filemode)

    formatter = logging.Formatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    fh.setFormatter(formatter)

    # add handler to logger object
    logger.addHandler(fh)

    if stdout:
        sh = logging.StreamHandler(sys.stdout)
        sh.setFormatter(formatter)
        logger.addHandler(sh)

    return logger
