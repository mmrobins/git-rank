git-rank

Use to rank contributors to a git project by lines of conribution.  This can be
done by blame lines for a current view of the project, or by log for a
historical view.  Includes options for breakdown by file, excluding authors and
files and filtering lines by regex.

# Installation

For now copy or symlink the git-rank file to somewhere in your path and add
git-rank/lib to your RUBYLIB to run from source.

Or you can build it as a gem yourself.  This is probably not recommended unless you're happy with the current functionality or are uncomfortable with modifying your PATH and RUBYLIB.  I'm not sure that shipping this as a gem is the right way to distribute it long term, as I'm guessing there may be a better way to add commands to git.  If you want the gem:

    gem build git-rank.gemspec
    gem install git-rank-0.0.1.gem

# Usage

See `git-rank --help` for usage info.  Note although most of the time you can
use `git rank` without the dash to run the command, when asking for help you
need the dash otherwise git tries to use the core code to look up help.

# Credits

Inspired by the git-rank-contributors script from http://git-wt-commit.rubyforge.org/git-rank-contributors
