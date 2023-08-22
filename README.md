# EEP Quest Management System
EEP-QMS is a quest management format and systems for integration to game engines. Intended to allow quest development by non coding quest designers.

It's format and components have been tested by several non computer gamers, with dungeon masters, tabletop gamers, and others who generally understand what a 'quest' is, being able to understand and read the files, and modify them with minimal instruction or guidance. 

# Capabilities
## Current
* Define quest information
* Game engine integration -Godot (Basic, no example reward support)

## Roadmap
### Short Term
* objective logic terms, greater than, less than, exactly, etc (if simple)
* .quest format extension for VS Code
* Game engine editor extension -Godot (A few tools, and file format allowance)
* Game engine integration -Unity

### Long Term
* Game engine integration -Unreal

# License
QMS is currently proprietary. Once groundwork has been laid, and feedback collected, an appropriate open source license will be selected.

# Goals
QMS was made to facilitate quest development by less programming oriented people. This is accomplished with a series of systems that manage quests in game, objective tracking and such. And a complimentary file format that presents relevant quest information in a visually succinct manner. It is intended to be structured enough that systems could be made to generate quests and questlines procedurally and output to that format for review.

## What is QMS NOT
* QMS is not a perfect solution. It was conceptualized with World of Warcraft style quests. Simple Go to X, do THING X times, return to quest giver. With creativity that can cover a broad possibility space. It may be expanded, but not at the expense of simmplicity or the format, as it was intended for writers and such to be able to create and develop quests.
* QMS is not an NPC dialog system.
* QMS is not a complete game. It may come with engine specific examples.
* QMS is not a plug and play solution. Due to the vast variety that game design incorperates, QMS cannot simply 'plug in' to an existing game and work. Other aspects of the game such as death events, player inventory events, travel events and more, need to be hooked into and set to send their signals or events to the QMS, which would then propogate it to the managed quests.

## Compliments to QMS

### IDE integration
* Syntax hilighting
* Objective verb hints?
* Reward syntax hints?
  * Objective VERB and reward systems are intended to be extensible and highly dependant on how either is integrated into the game.

### Game engine integration
* In engine quest editing plugins.
* Hook into defined verbs and rewards
* Check against other quests in the game Quests directory or database.