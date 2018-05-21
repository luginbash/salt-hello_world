base:
  '*':
    - default
  'exp*':
    - flaskApp
    - tensorflow-serving
    - nginx