## Test in Django

### When `settings` is set?

After you have run `python manage.py cmd`

### How to test `settings` of changing environment variables which are read in `settings`?

For example, in your `settings.py` you have:

```python
BEHAVIOUR = os.environ.get('some_key)
```

Run this:
```shell
# not set some_key
env -i VIRTUAL_ENV="$VIRTUAL_ENV" PATH="$PATH" python manage.py test

# or set some_key=x
env -i VIRTUAL_ENV="$VIRTUAL_ENV" PATH="$PATH" some_key=x python manage.py test
```

Using `from test.support import EnvironmentVarGuard` in test code does not help
because `settings.py` has already been loaded by test runner.

Using `modify_settings` or `with self.settings(LOGIN_URL='/other/login/'):` or
`override_settings` doesn't not work if you are testing the `settings` itself not
views or models.