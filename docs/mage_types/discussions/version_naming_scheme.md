#discussion

GAME.MILESTONE.patch
**Game** is for major changes that are not backwards compatible.

**Milestones** are for big, planned milestones. The specifics can be found in [[Roadmap]].
>[!example]
>v0.3.0 is the demo MVP & must-haves, 
>v0.4.0 might be for the demo MVP should-haves.

**patch** will be to indicate that source code/files have changed (not documentation). If this project were a team effort, this would allow each member determine whether they are running the latest version. These should, at minimum, be documented in commit messages.
>[!example]
>0 "v0.0.1"
>1 "Minor bug fixes."
>2 "Added new character controller."
>3 "Character can now jump."
>4 "v0.0.2"
>
>Commits 1-4 are part of v0.0.2. Team members should communicate before making a versioning commit. Commit 4 should only include documentation changes and the version number being updated in Godot.
