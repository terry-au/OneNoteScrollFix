## What is this?
If anyone has used OneNote on iOS, likely with a stylus/Apple Pencil/their finger, they may have come across a bug that results in the note page scrolling to the top upon undoing. This fixes that issue.

## Background
I contacted Microsoft about this bug in November. There has been several revisions of OneNote since then, but none have addressed this. I made this pretty quick fix just so that I could use OneNote without becoming frustrated. I think OneNote is a great application, but this bug made using it very cumbersome.

## How
The implementation for the fix is very simple. When the undo or redo button has its action invoked, prior to executing the action, a notification is sent to the scroll view (the document that can be drawn on). This notification invoked a method which enables blocking the setting of the scrollview's content offset, for a short period (0.01 seconds). Effectively, this means the call to scroll to the top is ignored.

## Donate
OneNoteScrollFix is free software, any donations are greatly appreciated but not required. Those wishing to donate may do so [here](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=DCPZ7LNKWPN6W&lc=AU&item_name=terry1994&item_number=MFHID&currency_code=USD&bn=PP%2dDonationsBF%3abtn_donateCC_LG%2egif%3aNonHosted).


## License
OneNoteScrollFix is licensed under the GPL v3 license. A copy of this license may be found in [here](LICENSE.md).
