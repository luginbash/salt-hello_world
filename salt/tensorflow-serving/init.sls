tf-serving-repo:
  pkgrepo.managed:
    - file: /etc/apt/sources.list.d/tensorflow-serving.list
    - key_url: https://storage.googleapis.com/tensorflow-serving-apt/tensorflow-serving.release.pub.gpg
    - name: deb [arch=amd64] http://storage.googleapis.com/tensorflow-serving-apt stable tensorflow-model-server tensorflow-model-server-universal

tensorflow-model-server:
  pkg.installed: []
  require:
    - pkgrepo: tf-serving-repo