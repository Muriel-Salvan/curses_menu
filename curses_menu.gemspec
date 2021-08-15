Gem::Specification.new do |spec|
  spec.name = 'curses_menu'
  spec.version = '0.0.1'
  spec.authors = ['Muriel Salvan']
  spec.email = ['muriel@x-aeon.com']
  spec.license = 'BSD-3-Clause'
  spec.required_ruby_version = '>= 2.6'

  spec.summary = 'Simple menu offering choices with navigation keys using curses'
  spec.homepage = 'http://x-aeon.com'

  spec.metadata['homepage_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir['lib/**/*'] + Dir['examples/**/*']
  spec.require_paths = ['lib']

  spec.add_dependency 'curses', '~> 1.4'

  # Test framework
  spec.add_development_dependency 'rspec', '~> 3.10'
  # Automatic semantic releasing
  spec.add_development_dependency 'sem_ver_components', '~> 0.3'
  # Lint checker
  spec.add_development_dependency 'rubocop', '~> 1.19'
  # Lint checker for rspec
  spec.add_development_dependency 'rubocop-rspec', '~> 2.4'
end
