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

