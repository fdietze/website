# Quality assurance for collaborative artifact creation
Goal: Manupulation resistant quality assurance for open and distributed communities that collaboratively work on a distributed artifact.

## Distributed communities, same type of artifact
There are multiple "communities" which collaborate on the same type of artifact. It can be imagined similarly to multiple forks of the same git repository, where every fork has a different group of maintainers. The contents of the individual repositories can diverge, but are compatible in the sense that they work on the same data structure with the same possible change actions and share the same "root commit".

## Distributed vs Centralized
This distrubuted approach can be used in a centralized manner, by disallowing the creation of new communities (forks) of that same artifact, if technically feasible.

## Good actions => more power
To participate in one of these communities, a user needs an account that maintains a reputation score (>= 0) per community. The general idea is: Accounts which do good actions for the community get more power in that community. Bad actions reduce the power. The reputation score represents how much these accounts are part of that community. The initial score when joining a community is zero. It cannot fall lower than that. This way, new participants have the same reputation as a bad actor. There is no sense to have accounts that have less power than newly created ones, because everyone can always create as many accounts as they want to in every community.

## Proposing and approving changes
In a community, every participant can propose changes to the artifact. Every change made to the artifact needs approval from other members. If a proposed change gets accepted, the user's reputation increases, if rejected, it decreases MORE than it would have increased on acceptance.  
Other members of the community can vote positively or negatively on the proposed change. The votes are weighted according to the voter's reputation (more reputation means more voting weight). 
Possible Attack: create many accounts, every account does one good change to gain some voting weight. Then all those accounts together can outvote high reputation members. This is hard to automate, because the proposed changes need to be useful.
Possible Mitigations:
- Reputation has quadratic influence on voting weight, such that few votes of high-reputation accounts are worth more than many votes of low-reputation accounts. Therefore, to outvote a high-reputation account, it takes either a VERY high number low-reputation accounts or another high-reputation account. And a lot of good changes need to be accepted on the way to create these accounts.
- Account age influences the weight, such that older accounts have more weight and it's harder to outvote them.
- Changes can only be accepted if at least one account with a reputation above a certain threshold participated. This way, many low-reputation accounts cannot accept changes alone.
- The voting weight for a reputation below a certain threshold is zero: Accounts need more than one approved change to gain voting power.

## Net positive attacks
Reputation penalty for rejected changes is higher than the reward for accepted changes. Therefore, attacks which abuse previously gained power, can only be net positive. They cannot destroy as much as they have already created. There are always more good changes than bad changes per artifact and community.

## Origin of changes
Proposed changes can originate from forks of other communities.
Draft working on changes that are not ready for proposal can be implemented using optimistic UIs or temporary copies of the artifact.

## Learning path
If needed, specific types of changes require a minimum reputation score to be proposed. This way, changes that require a lower skillset in the community (e.g. in argumentation), can be introduced first. Once the account gains more skills and therefore reputation they can propose more difficult changes.

## Preserving community culture
Everyone can start a new community and gets a high initial reputation in that new community. Teams working together on that artifact quickly get a similarly high reputation by accepting each-other's changes. Because power is distributed only from these initial high-reputation accounts, only new accounts which have the same sense of good actions as the initial accounts have a chance to gain reputation and join the community. This way, the initial culture of communities is conserved, even if the number of new participants increases drastically (which could happen, if a community got popular on social media).

## Gradual ownership between author and community
The change approval threshold can depend on different metrics. Example: The creation of a new piece of information. Initially, the author should have the right to edit that information without approval from others. Once more participants got involved, the threshold rised so that even changes from the original author need community approval (though less than from other members). At some point the piece of information is more owned by the community than the original author. 

## AI, bots and Guilds
Accounts are usually controlled by humans, but other scenarios are possible. Since the protocol is designed to be attack proof, there is no problem for AIs, bots and guilds to propose changes in the same way as everybody else does. They just need to play by the same reputation rules.

## Change flooding attacks and rate limiting
When there is no limit on creating new accounts, communities can be flooded with useless changes that drown legitimate change proposals of new users.
Possible Mitigations:
- Rate limiting zero-reputation change proposals using cryptographic puzzles like for creating new blocks in a blockchain
