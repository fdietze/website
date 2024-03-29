---
title: Improving the Hacker News Ranking Algorithm
excerpt: In our opinion, the goal of Hacker News (HN) is to find the highest quality submissions (according to its community) and show them on the front-page. While the current ranking algorithm seems to meet this requirement at first glance, we identified two inherent flaws.
author: [Felix Dietze, Johannes Nakayama]
---

*Update: [Comments on Hacker News](https://news.ycombinator.com/item?id=28391659)*

*Update 2: With all the learnings after writing this post, we built [Quality News](https://news.social-protocols.org), [read about it here.](https://github.com/social-protocols/news)*

In our opinion, the goal of Hacker News (HN) is to find the highest quality submissions (according to its community) and show them on the front-page. While the current ranking algorithm seems to meet this requirement at first glance, we identified two inherent flaws.

1. If a submission lands on the front-page, the number of upvotes it receives does not correlate with its quality. Independent of submission time, weekday, or clickbait titles.
2. There are false negatives. Some high quality submissions do not receive any upvotes because they are overlooked on the fast-moving new-page.


Let's look at these two issues in detail and try to confirm them with data and some systems thinking tools. [All HN submissions are available on BigQuery](https://console.cloud.google.com/marketplace/product/y-combinator/hacker-news), which we access via this [Kaggle notebook](https://www.kaggle.com/felixdietze/hacker-news-score-analysis). You can find the SQL queries for reproduction and further exploration in the Appendix.


## Number of Upvotes does not Correlate with Quality

We don't have a good definition for quality, except that users upvote submissions which they think are of high quality. But even high quality submissions get an inconsistent amount of upvotes. We have some data to back up this claim. Since HN allows URLs to be submitted multiple times, we can look at how many upvotes every submission of the same URL received. Note that submissions need at least two upvotes on the new-page to appear on the front-page and every submission starts with 1 upvote (submitters upvote). The number of upvotes is called `score` in the dataset. Let's look at URLs which have been submitted at least four times with the same title during 30 days where every submission got enough votes to show up on the front-page:


| title                                                                          | scores_by_time                |
|:-------------------------------------------------------------------------------|:------------------------------|
| Cameras and Lenses                                                             | [  14    7 2132    6]         |
| The Death of Microservice Madness in 2018                                      | [  5   3   5   5   4 993]     |
| It's later than you think                                                      | [  4  12   4 914]             |
| React Native for Android                                                       | [  5   6 907   6]             |
| The Deep Sea                                                                   | [  7   3   4   3  20   3 703] |
| Swift: Google’s Bet on Differentiable Programming                              | [ 13   9   3 675]             |
| Undercover reporter reveals life in a Polish troll farm                        | [  5  18   7 665]             |
| Edge Computing at Chick-fil-A                                                  | [  5   4   3 570]             |
| Why time management is ruining our lives                                       | [552   6   4   5   8]         |
| The Internet of Beefs                                                          | [  4   3   3 513]             |
| The Distribution of Users’ Computer Skills: Worse Than You Think               | [  3   5  32 512]             |
| All C++20 core language features with examples                                 | [  8   3   4 483]             |
| Giving GPT-3 a Turing Test                                                     | [  3   3  12  32 453]         |
| Static Analysis in GCC 10                                                      | [  8  18   9   3 394]         |
| Remote code execution in Homebrew by compromising the official Cask repository | [  4   4   4 387]             |
| Flawed Algorithms Are Grading Millions of Students’ Essays                     | [  7   3   6 358]             |
| Getting Started with Security Keys                                             | [ 12   5   8 346]             |
| Google Brain Residency                                                         | [337   3   3   7]             |
| Why is China smashing its tech industry?                                       | [ 10  15   7  10  12   6 311] |
| Why NetNewsWire Is Fast                                                        | [ 14   5   4 298]             |
| Statistics, we have a problem                                                  | [ 10   6   8 295]             |
| From First Principles: Why Scala?                                              | [  7   9   7 286]             |
| The rise and fall of the PlayStation supercomputers                            | [  4   3   4 283]             |
| Breaking homegrown crypto                                                      | [ 16   4   6   4 282]         |
| Random Acts of Optimization                                                    | [ 11   3  15 279]             |
| Escaping the SPA rabbit hole with modern Rails                                 | [ 15   5 274  10]             |
| My Fanless OpenBSD Desktop                                                     | [ 10  14   6   3 273]         |
| Attack Matrix for Kubernetes                                                   | [  9   7 272   3]             |
| Roadmap to becoming a web developer in 2017                                    | [  6   6   4 261]             |
| YouTube is now building its own video-transcoding chips                        | [ 19   8   3 259]             |


We observe that the scores are inconsistent. Only a few submissions score high. The low scores are a bit surprising because all submissions got enough votes to make it to the front-page. The high scores indicate that the community perceives these submissions as high quality. But these high-quality URLs have been submitted several times and received different, mostly low scores.

Can this observation be explained by different submission times? Let's look at submissions of the same URL with the lowest standard deviation of submission time-of-day.



| scores                | time_of_day      |   time_of_day_stddev |
|:----------------------|:-----------------|---------------------:|
| [  5   2   6 907   6] | [17 17 17 17 17] |            0.0397911 |
| [  7   2   2   5 107] | [15 14 15 15 17] |            1.00136   |
| [  2   3   2   2 127] | [14 10 12 11 11] |            1.23584   |
| [  1   2   1 134   1] | [13 13 13 15 16] |            1.41784   |
| [  2   5   1   4 173] | [13 13  8 12 12] |            1.93515   |
| [98  1  1  8  3]      | [21 21 21 17 18] |            2.07849   |
| [  3   3   1   1 117] | [17 19 21 17 21] |            2.1156    |
| [ 4  4  4  6 73]      | [14 14 18 18 14] |            2.44152   |
| [  5   5   4 182]     | [16 17 16 16]    |            0.363465  |
| [  3   3   2 143]     | [13 15 16 14]    |            1.08195   |
| [ 2  3  3 87]         | [15 16 15 18]    |            1.24167   |
| [  2   5   3 350]     | [14 14 17 14]    |            1.44038   |
| [ 4  1  2 89]         | [20 19 17 19]    |            1.44575   |
| [ 1  2  2 51]         | [1 1 2 5]        |            1.58321   |
| [  1   2   6 138]     | [14 12 15 12]    |            1.58531   |
| [  1   1   1 137]     | [20 20 20 16]    |            2.06964   |
| [ 1  2  1 85]         | [ 8 13  9 11]    |            2.18973   |
| [ 3  1  2 85]         | [ 9  8 13 12]    |            2.40206   |
| [ 1  1  4 61]         | [12 15 16 18]    |            2.46466   |
| [625   4   6]         | [19 19 19]       |            0.0288675 |

We observe that even for submissions submitted at the same time-of-day, the scores are inconsistent. This means that in general, score does not correlate well with quality. And we conclude that a low score of a single submission is not a good indicator for low quality.


## High Quality Content gets Overlooked

For a submission to be shown on the front-page, it needs to receive at least two upvotes (in addition to the submitter's vote). But most submissions don't get any upvotes at all. Here is a distribution of upvote counts for all submissions on Hacker News. Take minute to understand how to read the first two columns of this table. They answer questions like: How many submissions received between 3 and 4 upvotes?


| score_interval   |   submissions |   subm_fraction |   cumulative_subm_fraction |   total_votes |   votes_fraction |
|:-----------------|--------------:|----------------:|---------------------------:|--------------:|-----------------:|
| [1 1]            |       1790499 |        0.474718 |                   0.474718 |       1790499 |         0.037396 |
| [2 2]            |        771249 |        0.204483 |                   0.679201 |       1542498 |         0.032217 |
| [3 4]            |        502989 |        0.133358 |                   0.812559 |       1667519 |         0.034828 |
| [5 8]            |        215204 |        0.057057 |                   0.869617 |       1306686 |         0.027291 |
| [ 9 16]          |        124097 |        0.032902 |                   0.902519 |       1461785 |         0.030531 |
| [17 32]          |         92527 |        0.024532 |                   0.927051 |       2169840 |         0.045319 |
| [33 64]          |         95485 |        0.025316 |                   0.952367 |       4460504 |         0.093162 |
| [ 65 128]        |         86898 |        0.023039 |                   0.975406 |       7960106 |         0.166254 |
| [129 256]        |         59621 |        0.015807 |                   0.991214 |      10652590 |         0.222490 |
| [257 512]        |         25492 |        0.006759 |                   0.997972 |       8831357 |         0.184451 |
| [ 513 1024]      |          6514 |        0.001727 |                   0.999699 |       4387801 |         0.091643 |
| [1025 2031]      |          1025 |        0.000272 |                   0.999971 |       1356671 |         0.028335 |
| [2049 4022]      |           103 |        0.000027 |                   0.999998 |        262623 |         0.005485 |
| [4103 6015]      |             6 |        0.000002 |                   1.000000 |         28574 |         0.000597 |

![Histogram](/assets/2021-08-29-improving-the-hacker-news-ranking-algorithm/submission_and_votes_distribution_over_score_intervals.svg)

We observe that almost half of all submissions did not get any upvote at all (score = 1). It's also interesting to see that most votes get absorbed by few submissions which are on the frontpage (score 64-1024).

But are these submissions just spam and low-quality submissions? Let's have another look at the data and see if there are high quality URLs which have a submission without an upvote.


| title                                                                            | scores_by_time                            |
|:---------------------------------------------------------------------------------|:------------------------------------------|
| 2048                                                                             | [2903    1]                               |
| GitHub Sponsors                                                                  | [2082    1]                               |
| Zoom closes account of U.S.-based Chinese activist after Tiananmen event         | [   1 2003]                               |
| NPM and Left-Pad: Have We Forgotten How to Program?                              | [1725    1]                               |
| It Can Happen to You                                                             | [   5    1 1683]                          |
| A Protocol for Dying                                                             | [1610    1]                               |
| Extremely disillusioned with technology. Please help                             | [   1 1527]                               |
| Amazon Web Services in Plain English                                             | [1479    1  483]                          |
| Explain Shell                                                                    | [1372    2    1    2  775]                |
| Diamonds Suck (2006)                                                             | [   5 1336  392    1    2    2   51]      |
| Join the Battle for Net Neutrality                                               | [   1 1269]                               |
| Why did moving the mouse cursor cause Windows 95 to run more quickly?            | [   4    1 1188    1]                     |
| Fred's ImageMagick Scripts                                                       | [   6 1149    1]                          |
| FTC Probing Facebook for Use of Personal Data, Source Says                       | [1107    1]                               |
| Why nobody ever wins the car at the mall                                         | [   1 1104    1    2]                     |
| Deep Photo Style Transfer                                                        | [   1 1088]                               |
| Quick, Draw                                                                      | [  13 1083    1    1]                     |
| Laws of UX                                                                       | [   3    3  535    5    1    1    2 1037] |
| How to Center in CSS                                                             | [1036    1]                               |
| Google Dataset Search                                                            | [1035    1    1]                          |
| Cursors                                                                          | [1032    6    1    3    3    2]           |
| How to Build Good Software                                                       | [  20    4 1016    1    1]                |
| You might not need jQuery                                                        | [994   1]                                 |
| A new kind of map: it’s about time                                               | [  1 968]                                 |
| On Being a Principal Engineer                                                    | [  2   4   2   1 893]                     |
| 70TB of Parler users’ messages, videos, and posts leaked by security researchers | [  1 892]                                 |
| The Motherfucking Manifesto For Programming, Motherfuckers                       | [884   1   1   1]                         |
| Why I Quit Being So Accommodating (1922)                                         | [  1   2 866]                             |
| The Refragmentation                                                              | [852   2   4   3   1]                     |
| Things I Learnt from a Senior Software Engineer                                  | [  1 849]                                 |

We observe that there are indeed very high quality URLs that have been overlooked at least once on the new-page. This means that zero upvotes do not necessarily mean low quality. Zero upvotes mean uncertainty. But this uncertainty looks the same as low quality for the ranking algorithm and therefore gets penalized. This analysis shows that we do have false negatives with potential high quality among our zero upvote submissions.

# Why does this happen?

Explaining overlooked submissions on the new-page is simple: Not enough people look at the new-page to spot all high quality submissions. With the current amount of users and submission rate, many submissions just slip through the new-page without being noticed.

Explaining the score inconsistency for submissions that all appeared on the front-page is a bit more complicated. Let's understand the current ranking algorithm first.

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

![Positive Feedback loop. Three bubbles pointing at each other in a circle with a plus-sign on the arrows: "views" points to "upvotes", which points to "rank", which points to views. A fourth bubble "age" pointing with a minus-sign at "rank".](/assets/2021-08-29-improving-the-hacker-news-ranking-algorithm/feedback-loop.svg)

We define a view as a click by a registered user on a submission, so the user sees the submitted content. For [Ask HN](https://news.ycombinator.com/ask), the content would be the comments page. We only look at registered users, because these views are the only ones that can lead to more upvotes.

If many submissions compete for upvotes, the positive feedback loop creates a rich-get-richer phenomenon. Submissions with an already high number of upvotes are likely to get even more upvotes than others.

Every user acts on their own and decides when to visit the front-page and which submissions to vote on. If we imagine thousands of users looking at the front-page, the views and votes on the ranks follow a distribution where higher ranks receive more views than lower ranks. The graphic was created using the [Hacker News API](https://github.com/HackerNews/API) and observing score changes over time for every rank.

![Histogram of vote distribution by ranks on the front page. In decreasing ranks: 13%, 7%, 6%, 5%, 4%, 4%, 3% and flattening. With a hard drop on rank 30 (page 2)](/assets/2021-08-29-improving-the-hacker-news-ranking-algorithm/votehist.svg)

Let's imagine the just mentioned front-page in combination with those thousands of users, viewing and voting on the individual ranks. The first vote hitting a random rank increases the upvote count of that specific submission and pushes it to the top of the list. Now, that submission has a higher chance of receiving even more upvotes, but only because it received an upvote early.

If we run a second experiment and the first vote randomly hits a different rank and submission, then that specific submission has a better chance to get more upvotes. After many votes the ranking stabilizes and the high ranking submissions stay at high ranks while the lower ranked ones stay at lower ranks, without any chance to reach a high rank again.

Which submissions stabilize at high ranks depends on where the early votes land, which is completely random (submissions all have the same quality). This means that random submissions get high stable ranks even though they have the same quality.

With submissions **submitted at different points in time**, the age penalty kicks in and pulls stabilized random submissions back down. This allows other random rich submissions to exploit their feedback loop, get richer, and move up to higher ranks.

Now let's put everything back together and imagine submissions with **different qualities** on the front-page. A higher quality submission sitting on the same rank as a lower quality submission should get slightly more upvotes, because more users identify its quality and vote on it. But in reality, two submissions cannot have the same rank. One of the two submissions is ranked higher and therefore receives more views and upvotes. The difference in quality is not strong enough to outperform the different amount of votes coming in on different ranks.

This means, that **despite differences in the quality of submissions, random submissions rise to the top of the front-page**. Therefore, the number of votes does not correlate with a submission's quality. This is a very strong claim. Additionally to the data shown before, we're working on confirming this claim with a simulated front-page and will write about it in the future.





# How can the Ranking Algorithm be Improved?

We're working on alternative solutions with the following goals in mind:
- The algorithm should not produce false negatives, the community should find **all** high-quality content.
- Scores should correlate with quality so that submissions can be compared
- The quality of content on a future version of the front-page should be at least as high as on the current version of the front-page
- The user-interface should stay exactly the same
- The age penalty should behave the same way as it was designed
- Bonus: A higher overall quality on the frontpage
- Bonus: Make it more difficult to game the system


**The core idea of our approaches is to balance the positive feedback loop, such that instead of the rich getting richer and rising to the top, the highest quality rises to the top.**

There are many ways to do this. In our opinion, the following is the most promising one that can be implemented in Hacker News:

To balance the feedback loop, we add negative feedback: **More views of a submission should lead to a lower rank**. It turns the positive feedback loop into a **[balancing feedback loop](https://en.wikipedia.org/wiki/Negative_feedback)** that converges on the right amount of votes.

This can be achieved by normalizing the current ranking formula with the number of views:

```
               pow(upvotes, 0.8) / pow(ageHours + 2, 1.8)
rankingScore = ------------------------------------------
                                views + 1
```

![Balancing Positive Feedback loop. Like in in the previous diagram: three bubbles pointing at each other in a circle with a plus-sign on the arrows: "views" points to "upvotes", which points to "rank", which points to views. A fourth bubble "age" pointing with a minus-sign at "rank". Additionally to the previous diagram, there is an arrow with a minus-sign from "views" to "rank".](/assets/2021-08-29-improving-the-hacker-news-ranking-algorithm/feedback-loop-balanced.svg)

To understand why this works, imagine two submissions with the same number of upvotes and a different number of views. The article with more views probably has a lower quality than the one with fewer views, because more people have viewed it without giving an upvote. So the ratio of upvotes and views is a signal of quality.

By adding `/ views` to the formula, it contains exactly this ratio. Sorting by this ratio moves high-quality content to higher ranks. And at higher ranks, submissions get more views and upvotes, so the ratio becomes more accurate and converges. This makes the ratio comparable and thus a good indicator of quality. Interestingly, higher ratios will also have more upvotes, because of the ranking. And that is exactly what we are after: The number of upvotes correlates with quality.

This would solve the problem of correlation between upvote and quality on the front page. But high quality submissions can still be overlooked on the new page (false negatives).

The purpose of the new-page is to act as an initial filter and separate good from bad quality submissions. To achieve this goal, the new-page should expose every submission to a certain amount of views, to estimate its eligibility for the front-page.

To fulfill this purpose without false negatives, we propose to use the same front-page formula on the new-page. In this case the new-page would look almost the same as the front-page where high quality submissions are at the top. To unclutter the new-page and make room for new submissions, there could be an upvote threshold (= quality threshold), above which submissions are shown on the front-page and below which submissions are shown on the new-page.

## Early Simulations

We want to verify with simulations, if our proposal indeed meets the goals of Hacker News. In addition to that, we want to try other algorithms and see how those compare. Simplified proof of concept simulations already confirm that it's working as described.

Here are a few plots of our early, simplified simulations. In these simulations, all submissions are shown immediately on the frontpage and ranked by the formula. There is no new-page. Submissions have a predifined uniform random quality between 0 and 1. Random agents with an expectation threshold look at the frontpage and vote on submissions based on their quality. The agents look more freqently at higher ranks.

Please keep in mind that these simulations have simplified assumptions that do not correspond to reality. For example, the quality distribution is uniform and the vote distribution does not follow that of the real front page. The plots are there to show that our ideas can work. And we are currently working on creating better simulations.

### Original Hacker News formula
![Scatterplot with quality on x-axis (0-1) and upvotes on y-axis (0-120). The points roughly describe a filled triangle from (0 quality,0 upvotes) over (1 quality, 0 upvotes) to about (1 quality, 40 upvotes).](/assets/2021-08-29-improving-the-hacker-news-ranking-algorithm/hacker-news-upvote-quality-scatterplot.png)

Every point is a submission that went through the frontpage simulation. The x-axis shows its predefined quality and the y-axis its upvotes. We can see that higher quality content has the chance to reach higher scores. There are no false positives (low quality content with high score), but there are many false negatives (high quality content with low score). Some outliers have very high scores.

### Hacker News formula divided by views
If we use our proposed formula which divides the scoreRank by views, we get the following:
![Scatterplot with quality on x-axis (0-1) and upvotes on y-axis (0-35). The points roughly describe a thick fuzzy line from (0 quality,0 upvotes) to about (1 quality, 15 upvotes). There are almost no points in the area below the line (high quality, few upvotes).](/assets/2021-08-29-improving-the-hacker-news-ranking-algorithm/hacker-news-normalized-upvote-quality-scatterplot.png)

Now there are basically no false-negatives (high quality with low score) anymore and the upvotes correlate much better with quality.

# Conclusion and Future Work

We analyzed two problems of the current Hacker News ranking algorithm and confirmed them with data: 1) The number of upvotes does not correlate with quality. 2) High quality submissions are overlooked on the new-page. We explained that the root cause of these problems is the ranking algorithm itself. It introduces a rich-get-richer effect, which lets arbitrary high quality submissions rise to the top, while others don't get much attention. Additionally, the new-page does not get enough votes to identify all high-quality submissions.

We proposed a small modification to the Hacker News ranking formula, which turns the positive feedback loop into a balancing feedback loop: Dividing the result of the formula by the number of views a submission receives.

We already evaluated the effectiveness of this approach with oversimplified proof-of-concept simulations. And the results are quite promising. But there's more work to do. Currently, we're working on a more realistic simulation with the goal to behave the same as Hacker News in reality - including a new-page. If we're accurate enough, we can evaluate how different formulas change the resulting front-page. But more on that in the future.


Thanks for reading. We appreciate any feedback and ideas. We're also looking for ways to fund our research. Please get in touch!

# Appendix

## BigQuery sql queries

These queries can be run on the [Hacker News Dataset](https://console.cloud.google.com/marketplace/product/y-combinator/hacker-news) on BigQuery. You can fork our [Kaggle Notebook](https://www.kaggle.com/felixdietze/hacker-news-score-analysis) to start.

### All scores of urls with multiple submissions
```sql
-- note: score = upvotes + 1
SELECT
    title,
    ARRAY_AGG(score order by time ASC) as scores_by_time,
    DATE_DIFF(DATE(TIMESTAMP_SECONDS(MAX(time))),DATE(TIMESTAMP_SECONDS(MIN(time))), DAY) as days,
FROM `bigquery-public-data.hacker_news.full`
WHERE `type` = 'story' AND url != '' AND score IS NOT NULL AND score >= 3
GROUP BY url,title
HAVING COUNT(*) >= 4 AND days <= 30
ORDER BY max(score) DESC
LIMIT 30
```

### Scores of urls with multiple submissions at the same time of day

```sql
WITH
    stories AS (
        SELECT *
        FROM `bigquery-public-data.hacker_news.full`
        WHERE `type` = 'story' AND url != '' AND score IS NOT NULL AND score > 0
        ORDER BY time DESC
    )
SELECT
    ARRAY_AGG(score ORDER BY time) scores,
    ARRAY_AGG(EXTRACT(HOUR FROM timestamp) order by time ASC) time_of_day,
    stddev(EXTRACT(HOUR FROM timestamp)+EXTRACT(MINUTE FROM timestamp)/60) time_of_day_stddev,
    DATE_DIFF(DATE(TIMESTAMP_SECONDS(MAX(time))),DATE(TIMESTAMP_SECONDS(MIN(time))), DAY) as days,
FROM stories
GROUP BY url,title
HAVING
    COUNT(*) >= 3 AND COUNT(*) <= 10
    AND max(score) > 50
    AND days < 90
    AND time_of_day_stddev <= 2.5

ORDER BY count(score) DESC, time_of_day_stddev ASC
LIMIT 20
```

Note: We understand that the standard deviation of time-of-day should ideally be calculated using a [circular mean](https://en.wikipedia.org/wiki/Circular_mean), but we wanted to keep it simple.

### Distribution of upvote counts

For example: How many submissions got between 3 and 4 upvotes?

```sql
WITH
    stories AS (
        SELECT *
        FROM `bigquery-public-data.hacker_news.full`
        WHERE `type` = 'story' AND url != '' AND score IS NOT NULL AND score > 0
    ),
    intervals AS (    
        SELECT
            min(score) as min_score,
            max(score) as max_score,
            COUNT(*) as submissions,
            SUM(score) as total_votes,
        FROM
            stories
        GROUP BY
            ceil(log(score)/log(2))
    ),
    totals AS (
        SELECT
            count(*) AS total,
            sum(score) AS total_score,
        FROM stories
    )
SELECT
    max_score,
    [min_score, max_score] as score_interval,
    submissions,
    submissions / totals.total as subm_fraction,
    (SELECT COUNT(*) FROM stories where score <= max_score) / totals.total as cumulative_subm_fraction,
    total_votes,
    total_votes / totals.total_score as votes_fraction,
FROM
    intervals,
    totals
ORDER BY
    min_score ASC
```

### High quality submissions without upvotes


```sql
SELECT
    title,
    ARRAY_AGG(score order by time ASC) as scores_by_time,
FROM `bigquery-public-data.hacker_news.full`
WHERE `type` = 'story' AND url != '' AND score IS NOT NULL AND score > 0
GROUP BY url,title
HAVING COUNT(*) >= 2 AND min(score) = 1
ORDER BY max(score) DESC
LIMIT 30
```

## Alternative formulas

We also experimented with other balancing feedback loop formulas, that have interesting properties:

### Only downvotes
```
rankingScore = -(downvotes+1) * age
```

![Scatterplot with quality on x-axis (0-1) and downvotes on y-axis (-18 - 0). The points roughly describe a thick fuzzy line from (0 quality,-11 downvotes) to about (1 quality, -3 downvotes). There are almost no points in the area below the line (high quality, many downvotes).](/assets/2021-08-29-improving-the-hacker-news-ranking-algorithm/hacker-news-downvotes-quality-scatterplot.png)

Only having downvotes has very interesting properties. It's much harder to promote your own content. Also, uncertainty (few votes) gets more attention (higher rank) instead of less, like it does for upvote based systems. 

### Upvotes with views as downvotes
```
rankingScore = (upvotes-views-1) * age
```

![Scatterplot with quality on x-axis (0-1) and upvotes on y-axis (-16 - 0). The points roughly describe a thick fuzzy line from (0 quality,-11 upvotes) to about (1 quality, -3 downvotes). There are almost no points in the area below the line (high quality, many downvotes). The shape looks very similar to the one with only downvotes.](/assets/2021-08-29-improving-the-hacker-news-ranking-algorithm/hacker-news-views-as-downvotes-quality-scatterplot.png)

Interestingly, this formula seems to behave very similar to the downvote-only formula. Even though the users still have an upvote button.

