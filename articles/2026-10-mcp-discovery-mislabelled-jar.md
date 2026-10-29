# The Mislabelled Jar: What Five Chatbots Taught Me About AI Agents and Bad Tool Descriptions

*I asked Claude, Mistral, Gemini, ChatGPT and Copilot the same two questions about MCP tool discovery. Their answers agreed on the problem, disagreed on the details, and one of them accidentally demonstrated it.*

---

In September 1999, NASA's Mars Climate Orbiter arrived at Mars and promptly vanished. The spacecraft was fine and so was the maths. The cause was an interface: one team's ground software reported thruster data in pound-force seconds, while the navigation software assumed newton-seconds. Every number passed between them was valid. However, each number meant something different from what the receiving side believed, so for months the navigators steered with confidence, using figures that were wrong by a factor of about 4.45. The orbiter cost $125 million and ended up somewhere in the Martian atmosphere.

Nothing crashed or threw an error, and no alarm sounded. Two systems simply agreed on the format and disagreed on the meaning.

I kept thinking about that story while working with AI agents. Today an agent such as Claude Code can connect to databases, ticket systems and internal APIs through the **Model Context Protocol (MCP)**. When it connects, each server tells the agent what tools it offers and what they do. So I wondered what happens when that description is wrong.

Rather than speculate alone, I put two questions to five assistants: Claude, Mistral, Gemini, ChatGPT and Copilot. The full replies are in the companion comparison page. This article draws together what they found, where they agreed, and where things got interesting.

## First, what is "discovery"?

Picture an agent as a capable new hire on day one. It is smart and willing, but it has never seen your systems. Consequently, everything it knows about your tools comes from the labels on the jars.

In MCP, those labels arrive during **discovery**. When a server connects, it hands over a list of tools. Each tool comes with a name, a plain-language description and a schema that describes its inputs. For example:

```
name:        search_customers
description: Search customer records by name or email.
input:       query (string)
```

That's it. The agent reads the label, decides whether the tool fits the task, fills in the arguments and trusts whatever comes back. In practice, nothing checks that the label matches the contents. As Claude put it, a misleading description "isn't a metadata error, it's effectively a bad instruction the agent will follow with the same confidence it gives everything else."

## Question one: does a bad description actually matter?

I asked whether it was a real problem when discovery "wrongly identifies something about the data source or mischaracterises it."

All five said yes without hesitation. They used "a real issue", "a major issue" and, from Copilot, "a massive issue". More usefully, they agreed on *why* it matters. It isn't that things break loudly. Rather, things go wrong quietly.

### The silent failure

Mistral gave the clearest summary: "The failure isn't a crash — it's a plausible but wrong reasoning chain, which is worse because nothing signals the error."

Claude added the piece that makes it dangerous. Agents treat tool output as ground truth. A model will doubt its own memory long before it doubts a tool result. As a result, an error in a description upstream becomes a confident factual claim downstream.

Two examples from the replies make this concrete.

**The missing customer.** A tool is described as "search customer records", but it only indexes the last 90 days. You ask about a customer who signed up two years ago. The search returns nothing, so the agent reports that the customer doesn't exist. Worse, it may act on that absence, for instance by creating a duplicate account. Every step looks reasonable when you inspect it later, which is exactly why Claude called this "the nastiest class".

**The tidy but wrong report.** ChatGPT described a tool called `get_transactions` whose description says it returns *completed* transactions. In reality it returns everything, including pending, reversed and failed ones. The agent therefore totals the wrong population, flags reconciliation gaps that don't exist and produces a polished report that "passes superficial review." ChatGPT's verdict: "The tool has not failed technically. The failure is in the agent's understanding of the data."

If you have ever trusted a spreadsheet column labelled "Revenue" that turned out to be bookings, you already understand the problem.

### Six ways a label can lie

Between them, the five assistants listed a fairly complete set of failure shapes. I have condensed them here:

1. **Scope.** The tool covers less than it claims, such as one table, one region or the last 90 days. Empty results then look like facts.
2. **Parameter meaning.** Does `date` mean created or modified? Does `limit` count results or pages? The schema just says "string", so the agent guesses from the field name.
3. **Side effects.** MCP lets servers flag tools as read-only or destructive. However, these flags are optional, and the server writes them about itself. Copilot's example was a destructive tool described as a harmless "cleanup" utility. Claude noted that Claude Code uses these hints when deciding what to ask permission for, so a wrong flag can wave a risky call straight past the user.
4. **Output.** Most descriptions say nothing about what comes back. A field called `status` with values 1, 2 and 3 and no legend is, in Claude's words, "a coin flip."
5. **Drift.** The description was accurate when someone wrote it. Since then the database has changed, and nothing forces the two to stay in step.
6. **Crowding.** Connect three servers that each offer a `search` tool, and the agent picks whichever description sounds most like your request. Mistral called this "tool roulette". Copilot added the commercial twist: a well-described but worse tool will consistently beat a better but poorly described one, because "bad discovery metadata actively trains the agent to avoid your data source."

Several replies also mentioned the malicious cousin of all this. With **tool poisoning**, a description deliberately contains hidden instructions. Claude, however, made a point I found more sobering: the honest mistake "is more common and harder to notice."

## Question two: how much can discovery actually say?

If bad labels cause trouble, the obvious fix is better labels. So my second question asked how much information discovery can carry, and in what forms.

Here the answers were the most useful, because together they showed that discovery is not one list. It is several layers, and each layer reaches the agent differently.

- **The handshake.** On connection, the server names itself, declares its capabilities and can send an optional block of **instructions**. Claude Code places these instructions directly in the agent's context. Claude called this the most under-used field in the protocol, and Mistral called it the highest-bandwidth channel that most servers ignore. It is the natural place to say "here's what I don't cover" or "always call X before Y."
- **Tools.** Each tool has a name, a description, an input schema and, in newer versions, an output schema and behavioural hints.
- **Schema fields.** Every parameter can carry its own description, allowed values, formats and limits. Mistral argued that this is where precision is cheapest, because "structured schema information teaches the agent more per token than prose."
- **Resources.** These are readable data and documents, addressed by URI.
- **Prompts.** These are pre-written workflows, which Claude Code shows as slash commands.
- **Live updates.** The tool list can change mid-session, for instance after you log in.

So how much can it carry? Technically, almost unlimited. The protocol sets no length limit on descriptions. In practice, however, every word competes for space in the agent's context window with your code and your conversation. A server with 40 verbose tools can use a noticeable share of that space before the agent has done anything.

The most practical insight came from Claude: **where information lives matters as much as whether it exists.** The agent automatically sees the instructions and the tool definitions. It doesn't automatically read resources. So if a server places its honest scope statement in a resource called "about", the agent will never see it unless someone tells it to look.

It's like taping the allergy warning inside the cupboard door. The information is technically present, yet nobody reads it while cooking.

## How the five assistants differed

On the facts, the five largely agreed. On style and judgement, they differed in ways worth noting if you use them for research.

**Claude and Mistral** were the most precise about the protocol itself. They named specific fields and explained what Claude Code does with each one. Claude also warned that the spec changes every six to nine months, so details should be checked.

**ChatGPT** stepped back and treated the issue as a governance problem. It separated three failures: the agent doesn't find the tool, the agent misunderstands it, or the agent understands it but draws the wrong conclusion. It then proposed a validation stage before any agent relies on a tool for real business work. It also made the sharpest single point in the whole exercise: "a second LLM agreeing with the first does not establish correctness." In other words, asking another model to check isn't evidence.

**Gemini** was vivid and example-led. It was good on how vague names like `get_data` defeat tool search. However, it cited no sources, and a few of its claims went further than the protocol itself does.

**Copilot** was wide-ranging, and on the second question it drifted towards enterprise security scanning, which is a different topic. More interestingly, it quoted precise production statistics: error rates of "1% to 2%" with well-tuned descriptions against "5.7%" without. These figures came with footnote markers, but I couldn't trace them to a primary source.

I enjoyed the irony. Asked whether confident, unverified descriptions mislead their readers, one assistant supplied a confident, unverified description. That is the article's thesis in miniature, and a useful reminder: treat a chatbot's numbers exactly as you would treat an MCP tool's description. Read them, appreciate them, then check them.

## So what should you actually do?

The replies converged on a short, practical list. None of it is exotic, yet most servers skip it.

**If you build MCP servers:**

- **Write descriptions for a model, not a colleague.** Say what the tool does, what it *doesn't* cover and what an empty result means. "Searches orders from the last 90 days only; returns nothing for older orders" takes twelve words and prevents a whole class of errors.
- **Push detail into the schema.** "`date`: last-modified timestamp, ISO 8601, UTC" belongs on the field itself.
- **Use the instructions field.** One short paragraph about scope and ordering, which the agent will actually see.
- **Describe the output,** or offer a small `describe_schema` tool so the agent can orient itself before querying.
- **Prefer fewer, well-scoped tools** over dozens of overlapping ones.
- **Make errors helpful.** Copilot suggested a good pattern: rather than "invalid column", return "Invalid column 'X'. Did you mean 'Y'?" so the agent can correct itself.

**If you only use other people's servers:**

- **Correct the record locally.** A line in your project's `CLAUDE.md` such as "The Jira search only covers projects A and B" fixes a misleading description without touching the server.
- **Watch what the agent picks.** If it keeps choosing an unexpected tool, the description is usually the cause.
- **Test descriptions like code.** For ten prompts that should use a tool and ten that shouldn't, check which tool the agent actually chooses.

**If you design agent workflows for a business:** follow ChatGPT's principle. An agent shouldn't treat a tool as understood just because the tool exists and its calls succeed. Before anything consequential, verify what the tool *does*, not only what it *says*.

## Back to Mars

The Mars Climate Orbiter wasn't lost because anyone was careless with the arithmetic. It was lost because one side's assumption about meaning went unchecked. MCP tool descriptions sit in exactly that position. They are the specification the agent builds against. Yet we often write them as an afterthought, never test them and let them go stale.

The encouraging news is that the fix is mostly unglamorous: clear labels, honest limits and a habit of checking. Five different AI assistants, built by five different companies, reached that conclusion independently. One of them also showed, unintentionally, why it matters.

So label your jars, because the agent will believe every one of them.

---

*The full side-by-side replies from all five assistants, captured on 29 October 2026, are in the companion page "MCP Discovery Bot Comparison." Protocol details reflect the MCP specification at the time of writing; check modelcontextprotocol.io for the current version.*
