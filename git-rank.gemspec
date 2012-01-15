Gem::Specification.new do |s|
  s.name = 'git-rank'
  s.version = '0.0.1'
  s.authors = ['Matt Robinson']
  s.description = "Use to rank contributors to a git project by lines of conribution"
  s.email = 'mattr@mattrobinson.net'
  s.executables = ['git-rank']
  s.extra_rdoc_files = ['README']
  s.files = `git ls-files`.split("\n")
  s.homepage = 'http://github.com/mmrobins/git-rank'
  s.rdoc_options = ['--charset=UTF-8']
  s.require_paths = ['lib']
  s.required_rubygems_version = Gem::Requirement.new('>= 1.3.6')
  s.summary = s.description
  s.add_development_dependency 'rake', '~> 0.9'
end
