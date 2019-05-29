# python3 -m unittest test_function_decorator.py

import inspect
import logging
import unittest

logging.basicConfig(format='%(pathname)s:%(lineno)d %(message)s', level=logging.DEBUG)


class TestT2(unittest.TestCase):
    """You can create a nest function or call directly to your decorator

    Either way, they are the same.
    """
    def deco_with_args(self, setting='default'):
        logging.debug('Deecorating setting for the decorator is: %s', setting)
        def the_wrapper(func):
            def wrapper(*args, **kwargs):
                logging.debug("You are being wrapped")
                logging.debug("Positional args: %s", args)
                logging.debug("Keyword args: %s", kwargs)
                return func(*args, **kwargs)
            return wrapper
        return the_wrapper

    def worker(self, pos_arg=1, karg=''):
        logging.debug("Current function name: %s", inspect.stack()[0][3])
        logging.debug("Positional args: %s", pos_arg)
        logging.debug("Keyword args: %s", karg)

    def test_directly(self):
        self.deco_with_args('direct way')(self.worker)('pos_1', karg='my kwarg')
        self.assertTrue(True)
        logging.debug("Done with %s", inspect.stack()[0][3])

    def test_straightly(self):
        @self.deco_with_args('straight decoration')
        def a_worker(*args, **kwargs):
            self.worker(*args, **kwargs)

        a_worker('pos_2', karg='my kwarg 2')
        logging.debug("Done with %s", inspect.stack()[0][3])
