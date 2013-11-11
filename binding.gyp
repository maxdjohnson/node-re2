{
  'targets': [
    {
      'target_name': 're2',
      'sources': [
        'src/re2.cc',
        'src/RE2Wrapper.cc'
      ],
      'dependencies': [
        './vendor/re2/libre2.gyp:libre2'
      ]
    }
  ]
}
