# The Mislabelled Jar: Why AI Agents Believe Every Tool Description They Read

*When an AI agent connects to your systems, it learns what each tool does from a short description. If that description is wrong, nothing breaks. The agent simply gets the wrong answer with complete confidence.*

---

On the morning of 1 August 2012, Knight Capital, one of the largest trading firms in the United States, switched on new software for a stock-exchange programme. Within 45 minutes it had lost more than $460 million, which was more than the company could absorb.

The cause was a small piece of reused meaning. Years earlier, a particular flag in Knight's order system had switched on an old feature called Power Peg. That feature had long been retired, so the engineers repurposed the flag for the new programme. However, one of the eight servers never received the updated code. When the flag went live, seven servers read it as the new instruction. Meanwhile, the eighth read it the old way and began firing off millions of unintended orders.

Nothing in the message itself was malformed. The flag was valid and the servers were working. The trouble was that two parts of the same business attached different meanings to the same label, and nothing checked which meaning was in force.

That story is a useful lens for a newer problem. Today, an AI agent such as Claude Code can connect to databases, CRMs, ticketing systems and finance tools through the **Model Context Protocol (MCP)**. When it connects, each system describes its tools to the agent. So what happens when the description says one thing and the system does another?

## First, what is "discovery"?

Think of an agent as a capable new hire on their first day. They are bright and keen, but they have never seen your systems. Consequently, everything they know about your tools comes from the labels on the jars.

In MCP, those labels arrive during **discovery**. When a server connects, it hands over a list of tools. Each tool comes with a name, a plain-language description and a schema that defines its inputs. For example:

```
name:        search_customers
description: Search customer records by name or email.
input:       query (string)
```

That's it. The agent reads the label, decides whether the tool fits the task, fills in the arguments and trusts whatever comes back. In practice, nothing checks that the label matches the contents. As a result, a misleading description isn't really a metadata error. Instead, it is a bad instruction, which the agent follows with the same confidence it gives everything else.

## Why a bad label is worse than a broken tool

When a tool breaks, you get an error. Someone notices, and someone fixes it. When a tool is *mislabelled*, however, it works perfectly. It returns clean, valid data, and the agent reasons from it calmly and in the wrong direction.

There is a further twist. Agents treat tool output as ground truth. A model will doubt its own memory long before it doubts a tool result. So an error in a description upstream becomes a confident factual claim downstream, and by the time it reaches a person it looks like an answer.

Three examples show how this plays out in a business setting.

**The missing customer.** A tool is described as "search customer records", but it actually indexes only the last 90 days. You ask about a customer who signed up two years ago. The search returns nothing, so the agent reports that the customer doesn't exist. Worse, it may act on that absence, for instance by creating a duplicate account. Every step looks reasonable when reviewed later, which is exactly what makes this kind of error so hard to catch.

**The tidy but wrong report.** A tool called `get_transactions` says it returns *completed* transactions. In reality it returns everything, including pending, reversed and failed ones. The agent therefore totals the wrong population, flags reconciliation gaps that don't exist and produces a polished month-end report that survives a quick review. The tool hasn't failed. Rather, the agent's understanding of the data has.

**The promise you can't keep.** A customer-service agent checks a tool called `get_stock_level`, described as "units available for sale." In fact, the figure includes stock already allocated to other orders. The tool reports 40 units, so the agent confidently promises next-day delivery of 25. Unfortunately, only 5 are free. The customer finds out first, followed shortly by the warehouse, and the complaint lands with someone who never saw the agent's reasoning.

If you have ever trusted a spreadsheet column labelled "Revenue" that turned out to be bookings, you already understand the problem.

## Six ways a label can lie

In practice, mislabelling tends to take one of six shapes.

1. **Scope.** The tool covers less than it claims, such as one table, one region or the last 90 days. Empty results then look like facts.
2. **Parameter meaning.** Does `date` mean created or modified? Does `limit` count results or pages? The schema just says "string", so the agent guesses from the field name.
3. **Side effects.** MCP lets servers flag tools as read-only or destructive. These flags, however, are optional, and the server writes them about itself. A destructive tool described as a harmless "cleanup" utility can therefore slip through. Moreover, Claude Code uses these flags when deciding what to ask permission for, so a wrong flag can wave a risky action straight past the user.
4. **Output.** Most descriptions say nothing about what comes back. A field called `status` with values 1, 2 and 3 and no legend is a coin flip.
5. **Drift.** The description was accurate when someone wrote it. Since then the database has changed, and nothing forces the two to stay in step. This is the Knight Capital pattern: a label whose meaning moved on while part of the system didn't.
6. **Crowding.** Connect three systems that each offer a `search` tool, and the agent picks whichever description sounds most like your request. Tool choice becomes roulette. There is also a commercial edge here: a well-described but weaker tool will consistently beat a stronger but poorly described one. In effect, bad metadata trains the agent to avoid your data.

There is also a malicious version of this problem. In **tool poisoning**, a description deliberately carries hidden instructions. Even so, the honest mistake is far more common, and it is much harder to notice.

## How much can a label actually say?

If bad labels cause the trouble, the obvious fix is better labels. Fortunately, MCP discovery is richer than a single list. It has several layers, and each one reaches the agent differently.

- **The handshake.** On connection, the server names itself, declares what it supports and can send an optional block of **instructions**. Claude Code places these instructions directly in the agent's context. This is the most under-used field in the protocol, yet it is the natural place to say "here's what I don't cover" or "always call X before Y."
- **Tools.** Each tool has a name, a description, an input schema and, in newer versions, an output schema and behaviour flags.
- **Schema fields.** Every parameter can carry its own description, allowed values, formats and limits. This is where precision is cheapest, because structured detail teaches the agent more per word than prose does.
- **Resources.** These are readable data and documents, each with its own address.
- **Prompts.** These are pre-written workflows, which Claude Code offers as slash commands.
- **Live updates.** The tool list can change mid-session, for instance after you log in.

So how much can it carry? Technically, almost unlimited. The protocol sets no length limit on descriptions. In practice, however, every word competes for space in the agent's working memory, alongside your documents and your conversation. A server with 40 wordy tools can use a noticeable share of that space before the agent has done anything useful.

The most practical point is this: **where information lives matters as much as whether it exists.** The agent automatically sees the instructions and the tool definitions. By contrast, it doesn't automatically read resources. So if a server places its honest scope statement in a resource called "about", the agent will never see it unless someone tells it to look.

It's like filing the product recall notice in the archive room. Technically, the information is on the premises. Yet nobody on the shop floor will ever read it.

## A note on confidence

One further lesson applies well beyond MCP. When an agent's understanding of a tool is in doubt, it is tempting to ask a second AI model to check the first. However, a second model agreeing with the first is not evidence. Both are reading the same label, so both inherit the same mistake. Real verification needs something independent: source documentation, a known test case or a controlled, read-only trial run.

A simple test case often does the job. For instance, if you know a particular customer signed up in 2019, ask the agent to find them. If it can't, the search tool's description is overstating its reach, and you have learned that in minutes rather than after a duplicate account or a missed renewal.

The same caution applies to the figures that circulate about agent reliability. Precise-sounding error rates are easy to find and hard to trace. Treat them exactly as you would treat a tool description: read them, find them useful, and then check them before you rely on them.

## So what should you actually do?

The remedies are short and practical. None of them is exotic, yet most systems skip them.

**If you build MCP servers:**

- **Write descriptions for a model, not a colleague.** Say what the tool does, what it *doesn't* cover and what an empty result means. "Searches orders from the last 90 days only; returns nothing for older orders" takes twelve words and prevents a whole class of errors.
- **Push detail into the schema.** "`date`: last-modified timestamp, ISO 8601, UTC" belongs on the field itself.
- **Use the instructions field.** One short paragraph about scope and ordering, which the agent will actually see.
- **Describe the output,** or offer a small `describe_schema` tool so the agent can orient itself before querying.
- **Prefer fewer, well-scoped tools** over dozens of overlapping ones.
- **Make errors helpful.** Rather than "invalid column", return "Invalid column 'X'. Did you mean 'Y'?" so the agent can correct itself.

**If you only use other people's servers:**

- **Correct the record locally.** A line in your project's `CLAUDE.md` such as "The Jira search only covers projects A and B" fixes a misleading description without touching the server.
- **Watch what the agent picks.** If it keeps choosing an unexpected tool, the description is usually the cause.
- **Test descriptions like code.** For ten prompts that should use a tool and ten that shouldn't, check which tool the agent actually chooses.

**If you design agent workflows for a business:** adopt one simple principle. An agent shouldn't treat a tool as understood just because the tool exists and its calls succeed. Before anything consequential, such as a payment, an approval or a report to the board, verify what the tool *does*, not only what it *says*. In practice, that means recording what each tool claims, what testing shows it actually does, and what conclusions it can safely support.

## Back to the trading floor

Knight Capital wasn't brought down by bad maths or a hostile attack. It was brought down by a label whose meaning had shifted, and by the absence of any check on which meaning applied. MCP tool descriptions sit in exactly that position. They are the specification the agent works from. Yet we often write them as an afterthought, never test them and let them go stale.

The encouraging news is that the fix is mostly unglamorous: clear labels, honest limits and a habit of checking. Those habits are cheap, whereas the alternative, as Knight discovered, can cost a company in under an hour.

So label your jars, because the agent will believe every one of them.

---

*Protocol details reflect the MCP specification at the time of writing (October 2026); check modelcontextprotocol.io for the current version. Knight Capital figures are from the US Securities and Exchange Commission's 2013 order on the incident.*
