NagiDev's DialogueNodes addon is great at what it does, but when modifying its code I can't help but wonder if I could make it much simpler. 
# Requirements
- Script inputs should be editable in a text editor
- Should be able to play blocking and nonblocking cutscenes
- Display speaker's name, as well as (animated) sprite
- Interface with StoryManager to update story variables
- Interface with OverworldConnector for battles
- Emit StoryManager.DialogSignals
- Support conditional branching

# Examples
Lines preceded with 1+ `>` chars will be part of a branch. This will work similar to Reddit comment threads.

`>Mentor (happy): This will be printed to the text box.`
This would lookup the Mentor character, checking for a happy sprite. Everything after the colon will be printed to a RichTextLabel.

## Event Blocks
`[event-name]`
This would trigger an event, using the string value provided within the brackets. Until this event is completed, the player will not be able to skip forward. This could be a battle, cutscene.

`<event-name>`
Like the block above, this will play an event. However, if the player skips the dialog, the event will also be skipped.

`|event-name|`
Like the first event block, except while the event is playing the dialog box and related elements will be hidden.

