+++
title = "Hacker News Ranking is Chaotic"
description = "A closer look at the Hacker News front-page formula and why early random votes can create chaotic ranking outcomes."
date = 2023-04-12
aliases = ["2023/04/12/hacker-news-ranking-is-chaotic.html"]
draft = true

[extra]
authors = ["Felix Dietze", "Johannes Nakayama"]
+++

The new-page is showing the latest submissions, ordered by submission time. To calculate the front-page, the algorithm takes the newest 1500 submissions which have at least two upvotes, applies the ranking formula and sorts by the resulting value. Here is the [formula](https://medium.com/hacking-and-gonzo/how-hacker-news-ranking-algorithm-works-1d9b0cf2c08d):

```
rankingScore = pow(upvotes, 0.8) / pow(ageHours + 2, 1.8)
```

To understand the formula, let's oversimplify it. An exponent of `0.8` is almost linear and an exponent of `1.8` is almost quadratic. We also ignore the `+ 2`:

```
upvotes / ageHours^2
```

It means that the submissions on the front-page are basically ordered by their number of upvotes with a quadratic age penalty. At the age of 2 hours, the upvotes count only as `1/2^2 = 1/4 = 25%`, after 5 hours only `1/5^2 = 1/25 = 4%` and after 25 hours a submission's score counts just `1/25^2 = 1/625 = 0.16%`.

Now let's imagine a front-page where all submissions have **exactly the same quality** and were submitted at **exactly the same time**. The front-page would just sort the submissions by their number of votes because they all have the same age penalty. Higher ranked submissions get more views and therefore more upvotes, which results in an even higher rank, more views, more upvotes and so on. This is called a [positive feedback loop](https://en.wikipedia.org/wiki/Positive_feedback).

![Positive Feedback loop. Three bubbles pointing at each other in a circle with a plus-sign on the arrows: "views" points to "upvotes", which points to "rank", which points to views. A fourth bubble "age" pointing with a minus-sign at "rank".](/posts/improving-the-hacker-news-ranking-algorithm/feedback-loop.svg)

If many submissions compete for upvotes, the positive feedback loop creates a rich-get-richer phenomenon. Submissions with an already high number of upvotes are likely to get even more upvotes than others.

Every user acts on their own and decides when to visit the front-page and which submissions to vote on. If we imagine thousands of users looking at the front-page, the views and votes on the ranks follow a distribution where higher ranks receive more views than lower ranks. The graphic was created using the [Hacker News API](https://github.com/HackerNews/API) and observing score changes over time for every rank.

![Histogram of vote distribution by ranks on the front page. In decreasing ranks: 13%, 7%, 6%, 5%, 4%, 4%, 3% and flattening. With a hard drop on rank 30 (page 2)](/posts/improving-the-hacker-news-ranking-algorithm/votehist.svg)

Let's imagine the just mentioned front-page in combination with those thousands of users, viewing and voting on the individual ranks. The first vote hitting a random rank increases the upvote count of that specific submission and pushes it to the top of the list. Now, that submission has a higher chance of receiving even more upvotes, but only because it received an upvote early.

If we run a second experiment and the first vote randomly hits a different rank and submission, then that specific submission has a better chance to get more upvotes. After many votes the ranking stabilizes and the high ranking submissions stay at high ranks while the lower ranked ones stay at lower ranks, without any chance to reach a high rank again.

Which submissions stabilize at high ranks depends on where the early votes land, which is completely random (submissions all have the same quality). This means that random submissions get high stable ranks even though they have the same quality.

With submissions **submitted at different points in time**, the age penalty kicks in and pulls stabilized random submissions back down. This allows other random rich submissions to exploit their feedback loop, get richer, and move up to higher ranks.

Now let's put everything back together and imagine submissions with **different qualities** on the front-page. A higher quality submission sitting on the same rank as a lower quality submission should get slightly more upvotes, because more users identify its quality and vote on it. But in reality, two submissions cannot have the same rank. One of the two submissions is ranked higher and therefore receives more views and upvotes. The difference in quality is not strong enough to outperform the different amount of votes coming in on different ranks.

This means, that **despite differences in the quality of submissions, random submissions rise to the top of the front-page**. Therefore, the number of votes does not correlate with a submission's quality. This is a very strong claim. Additionally to the data shown before, we're working on confirming this claim with a simulated front-page and will write about it in the future.
