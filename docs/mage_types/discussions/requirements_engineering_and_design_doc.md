#discussion #process_notes
https://medium.com/design-bootcamp/a-guide-to-requirements-engineering-572193bd2739
https://www.geeksforgeeks.org/functional-vs-non-functional-requirements/
# Elicitation
`Getting a list of requirements.`

I like to imagine I'm opening the app/game/etc for the first time. What do I see? This gives me a list of `required functionality`. Then, by analyzing how different functions must interact, I can group these functions into `systems`. The output for this process is a large list of loosely organized requirements.

>[!danger]
>The main issue I need to improve in this regard is how unwieldy this list is. It is intimidating to look at and feels rather inflexible.

Potential Improvements:
- Keep each requirement item simple. Absolutely no implementation details!
	- This will keep the requirements list from getting outdated during prototyping.

# Analysis
`Ensure list of requirements are comprehensive, viable, prioritized, and consistent.`

Previously, the output for this section would be the comprehensive requirements list. However, from keeping that list from getting bloated and unwieldy, I think this process should be done separately.
## Categorization
Requirements are labelled as either *functional* or *non-functional*.

*Functional* requirements describe what the system should do. These describe the features the user/player will see in the end product.

*Non-functional* requirements describe how the program should work. Examples include:
- Portability
- Security
- Maintainability
- Reliability
- Scalability
- Performance
- Reusability
- Flexibility

>[!example]
>Online Banking System
>
>Functional Requirements:
>
>- Users should be able to log in with their username and password.
>- Users should be able to check their account balance.
>-  Users should receive notifications after making a transaction.
>
> Non-functional Requirements:
> - The system should respond to user actions in less than 2 seconds.
>  -  All transactions must be encrypted and comply with industry security standards.
> -    The system should be able to handle 100 million users with minimal downtime.

## Prioritization
Separating requirements into the following categories:
- Must-have
- Should-have
- Could-have
- Won't-have
# Documentation
`Communicating requirements to stakeholders and developers.`

This would be a good place to incorporate the roadmap.

Requirements should have the following attributes:
- Unique id
- Author
- Acceptance criteria
- Name
- Category
- Comments
- Description
- Priority
- Resolution
- Source
- Version history

# My Process
Ultimately, I'm looking for a comprehensive todo list which, when completed, will yield the MVP. I need this todo list to mesh with the specifications document and roadmap.

**Requirements** should be high-level enough that implementation details will not affect them. I'm essentially looking for *functional-requirements*: only stuff the player will notice. *Non-functional* requirements should be collected at the top or bottom of the requirements document.

The **roadmap** will expand on these requirements, subdividing them into atomized steps. Each of these steps are given a priority and status (whether they have been completed, etc). These sub-requirements should have the ability to be sorted into **release versions**.

**Specifications** should detail how specific requirements will be implemented, and how these implementations will interact together. Requirements with high-levels of interaction should be grouped into **systems**. These systems in turn will act as black boxes, with defined inputs and outputs. This document should describe how these systems work, how to use them, why they were designed the way they were, and any relevant quirks.

The **specifications** and **roadmap** should be updated as the project progresses, while the core **requirements** should ideally not be touched.

## My Design Doc Evolution
Initially, I broke my design doc into 3 parts *Background*, *Technical*, and *Design*. I didn't have a clear concept of what the lattermost part would entail, something about communicating how utilize the systems built up in *Technical*. *Technical* was broken into two subparts: requirements and specifications, where specifications would describe the implementation details (think UML diagrams). This section later morphed into *Roadmap*, which added chronological structure to the requirements list.

In the future, I plan to use *Background*, *Requirements*, and *Roadmap*. *Background* is for lore, similar high level artistic details, and brief introductions for the game's main mechanics. *Requirements* is a braindump document, comprehensively detailing every Todo list item necessary for the MVP. Once this document is completed, it should be organized into the *Roadmap*, which will provide loose chronological structure.

At this stage, the *Roadmap* will become the main portion of the design doc. The top of this document organizes all remaining requirements into a *version list*. Each version list should have a focus/goal, as well as a [[version_naming_scheme|name]]. As these lists get further from the current version, they'll be less accurate. I typically try to take a moment to refactor these lists every time I finish the current one.

I've typically just deleted the previous list whenever its completed, but I think it could be worth saving these into a *Changelog* document, just detailing what specifically was included in that version and what was moved to later lists.

Finally, I regret not keeping some form of *Devlog*, detailing what I did every day. The main utility of such a document would be in formulating my reasoning for certain decisions. I've frequently found myself returning to specific mechanics, trying to implement them and realizing why I gave up previously. It'd be helpful to have a devlog I could return to that would save me that work. This would also be a good space for describing how different systems and mechanics work.
## Design Doc 4/25/26
Here's my current understanding of my process (i.e. how I think I will plan my next project):
1. Requirement Generation: Getting a near exhaustive list of requirements
	1. Imagine opening game and playing through its starting level (or some hypothetical debug room)
	2. Take notes about what happens and what components I would need
2. Requirement Organization: Create Roadmap.md. Organize requirements under headers. Try to keep the number of headers low and have only 2 levels of headers (e.g. # Battle and ## Action Effects).
3. Specifications: Requirements focus on "what" needs to be done, while specs focus on "how." 
	1. Group requirements into "systems," which can all act independently from each other
	2. Discussions and descriptions of these systems should be included in Roadmap.md, as close to related reqs as reasonable. 
	3. Long discussions should be extracted into their own file, with the link in the relevant section
4. Using Obsidian tags and the Cardboard addon, group requirements into version releases