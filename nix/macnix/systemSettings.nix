# run 'darwin-help' in CLI and then search for system.defaults.* for a full list
# of mac settings options

{ config, lib, pkgs, ... }:

{
# Script to symlink applications to spotlight
# Make sure to add 'rsync' to package list
system.activationScripts.postUserActivation.text = ''
  apps_source="${config.system.build.applications}/Applications"
  moniker="Nix Trampolines"
  app_target_base="$HOME/Applications"
  app_target="$app_target_base/$moniker"
  mkdir -p "$app_target"
  ${pkgs.rsync}/bin/rsync --archive --checksum --chmod=-w --copy-unsafe-links --delete "$apps_source/" "$app_target"
'';

# Whether to enable quarantine for downloaded applications
system.defaults.LaunchServices.LSQuarantine = false;
# Set to ‘Dark’ to enable dark mode, or leave unset for normal mode
system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
# Jump to the spot that’s clicked on the scroll bar
system.defaults.NSGlobalDomain.AppleScrollerPagingBehavior = true;
# Whether to show all file extensions in Finder
system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
system.defaults.finder.AppleShowAllExtensions = true;
# When to show the scrollbars. Options are ‘WhenScrolling’, ‘Automatic’ and ‘Always’.
system.defaults.NSGlobalDomain.AppleShowScrollBars = "Always";
# Whether to enable automatic capitalization. The default is true.
system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
# Whether to enable smart dash substitution. The default is true.
system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
# Whether to enable inline predictive text. The default is true.
system.defaults.NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
# Whether to enable smart period substitution. The default is true.
system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
# Whether to enable smart quote substitution. The default is true.
system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
# Whether to enable automatic spelling correction. The default is true.
system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
# Whether to use expanded save panel by default. The default is false.
system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
# Automatically install Mac OS software updates
system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
# Grouping strategy when showing windows from an application. false means “One
# at a time” true means “All at once”
system.defaults.WindowManager.AppWindowGroupingBehavior = false;
# Click wallpaper to reveal desktop Clicking your wallpaper will move all
# windows out of the way to allow access to your desktop items and widgets.
# Default is true. false means “Only in Stage Manager” true means “Always”
system.defaults.WindowManager.EnableStandardClickToShowDesktop = false;
# Enable Stage Manager Stage Manager arranges your recent windows into a single
# strip for reduced clutter and quick access. Default is false.
system.defaults.WindowManager.GloballyEnabled = false;
# Whether to automatically hide and show the dock. The default is false.
system.defaults.dock.autohide = true;
# Magnified icon size on hover between 16 and 128. The default is 16.
system.defaults.dock.largesize = 60;
# Size of the icons in the dock. The default is 64.
system.defaults.dock.tilesize = 48;
# Magnify icon on hover. The default is false.
system.defaults.dock.magnification = true;
# Whether to automatically rearrange spaces based on most recent use
system.defaults.dock.mru-spaces = false;
# # Apps to have in the dock
# system.defaults.dock.persistent-apps = [];
# # Folders to have showing in the dock
# system.defaults.dock.persistent-others = [];
# Show recent applications in the dock. The default is true.
system.defaults.dock.show-recents = false;
# Hot corner action for bottom left corner
system.defaults.dock.wvous-bl-corner = 4;
# Hot corner action for bottom right corner
system.defaults.dock.wvous-br-corner = 4;
# Hot corner action for top left corner
system.defaults.dock.wvous-tl-corner = 2;
# Hot corner action for top right corner
system.defaults.dock.wvous-tr-corner = 2;
# Change the default search scope. Use “SCcf” to default to current folder. The
# default is unset (“This Mac”).
system.defaults.finder.FXDefaultSearchScope = "SCcf";
# Change the default finder view. “icnv” = Icon view, “Nlsv” = List view, “clmv”
# = Column View, “Flwv” = Gallery View The default is icnv.
system.defaults.finder.FXPreferredViewStyle = "Nlsv";
# Change the default folder shown in Finder windows. options in darwin-help
system.defaults.finder.NewWindowTarget = "Documents";
# Show path breadcrumbs in finder windows. The default is false.
system.defaults.finder.ShowPathbar = true;
# Show status bar at bottom of finder windows with item/disk space stats. The
# default is false.
system.defaults.finder.ShowStatusBar = true;
# Whether to show the full POSIX filepath in the window title. The default is false.
system.defaults.finder._FXShowPosixPathInTitle = true;
# Keep folders on top when sorting by name. The default is false.
system.defaults.finder._FXSortFoldersFirst = true;
# Keep folders on top when sorting by name on the desktop. The default is false.
system.defaults.finder._FXSortFoldersFirstOnDesktop = true;
# Enable guest account
system.defaults.loginwindow.GuestEnabled = false;
# Whether to enable trackpad tap to click. The default is false.
system.defaults.trackpad.Clicking = true;
# Whether to enable tap-to-drag. The default is false.
system.defaults.trackpad.Dragging = true;
# 0 to disable three finger tap, 2 to trigger Look up & data detectors.
# The default is 2.
system.defaults.trackpad.TrackpadThreeFingerTapGesture = 0;
# Whether to enable trackpad right click. The default is false.
system.defaults.trackpad.TrackpadRightClick = true;
# enable/disable startup chime
system.startup.chime = false;
}
