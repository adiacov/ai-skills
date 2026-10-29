# Test cases

Example requests for checking that the skill triggers and behaves as expected.
Try them in a fresh agent session after changing the skill.

## Should trigger

1. **Request:** "Can you help me understand this paper? https://arxiv.org/abs/1301.3781"
   **Expect:** Fetches the paper (HTML or abstract page, then PDF), replies with a 3–4
   sentence orientation (title, problem, main idea, main result), then asks where to
   start. No section-by-section summary.

2. **Request:** "What does 'we define the computational complexity of a model as the
   number of parameters that need to be accessed' mean?"
   **Expect:** Full treatment: everyday analogy, what it means in the paper, maybe a
   tiny example, at most 1–3 real links, and one short check question at the end.

3. **Request:** "What does SOTA mean?"
   **Expect:** One or two sentences. No analogy, no links, no follow-up quiz.

4. **Request:** "Explain p-value like I'm five."
   **Expect:** Explained without a paper, in plain language, with an analogy and a
   tiny numeric example. No formula unless asked.

5. **Request:** "I don't get Figure 3, what am I looking at?" (with a paper loaded)
   **Expect:** Explains the axes, what one point or line represents, and the single
   takeaway the authors intend.

6. **Request:** "Still too hard." (after an explanation)
   **Expect:** Starts over with a different analogy instead of repeating the first
   one more slowly.

7. **Request:** "Here's the link: <paywalled journal URL>"
   **Expect:** Says plainly it cannot access the text and asks for the PDF or the
   passage. Does not reconstruct the paper from its title.

## Should NOT trigger

1. **Request:** "Help me write the related-work section of my paper."
   **Why:** Writing a paper, not understanding one.

2. **Request:** "Review this manuscript as a NeurIPS reviewer and score it."
   **Why:** Peer review needs critique for experts, not beginner explanations.

3. **Request:** "Why does this Python function throw a KeyError?"
   **Why:** Debugging code, not explaining a research idea.
