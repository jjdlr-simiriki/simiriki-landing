/*
 * Azure Static Web Apps API route to handle post‑payment logic for Simiriki.
 *
 * This handler verifies a completed Stripe Checkout session and, when the
 * payment has been successfully captured, forwards the purchaser details to
 * the Simiriki guide generator function. It expects a JSON body with a
 * `session_id` field. Stripe credentials and downstream endpoints are read
 * from environment variables:
 *
 *   STRIPE_SECRET_KEY      – your Stripe secret API key
 *   GUIDE_FUNCTION_URL     – the full URL of the Azure Function that generates
 *                            and emails the personalized guide
 *   AFTER_PAYMENT_SECRET   – secret header value required by the Azure
 *                            Function (matches the one defined in app settings)
 */

const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

module.exports = async function (context, req) {
  try {
    // Ensure a session ID was provided
    const { session_id } = req.body || {};
    if (!session_id) {
      context.log.warn('No session_id provided in request body');
      context.res = { status: 400, body: { error: 'Missing session_id' } };
      return;
    }

    // Retrieve the checkout session from Stripe
    const session = await stripe.checkout.sessions.retrieve(session_id, {
      expand: ['customer', 'customer_details'],
    });

    // Only proceed if the session has been paid
    if (session.payment_status !== 'paid') {
      context.log.warn(`Session ${session_id} is not paid – status: ${session.payment_status}`);
      context.res = { status: 202, body: { status: 'unpaid' } };
      return;
    }

    // Extract purchaser details and custom metadata
    const email = session.customer_details?.email;
    const name = session.customer_details?.name || '';
    // Expecting metadata fields (passed when creating the session) for company and answers
    const company = session.metadata?.company || '';
    let answers;
    try {
      answers = session.metadata?.answers ? JSON.parse(session.metadata.answers) : {};
    } catch (err) {
      // Malformed JSON in metadata; fall back to empty answers
      context.log.error('Unable to parse survey answers from metadata:', err);
      answers = {};
    }

    // Construct payload for guide generator
    const payload = {
      name,
      email,
      company,
      answers,
    };

    // Forward to your Azure Function that builds the PDF and sends email
    const guideFunctionUrl = process.env.GUIDE_FUNCTION_URL;
    const secretHeader = process.env.AFTER_PAYMENT_SECRET;

    if (!guideFunctionUrl || !secretHeader) {
      context.log.error(
        'GUIDE_FUNCTION_URL or AFTER_PAYMENT_SECRET environment variables are missing',
      );
      context.res = { status: 500, body: { error: 'Server misconfiguration' } };
      return;
    }

    // Use native fetch (available in Node 18+). If using an older Node
    // runtime, install `node-fetch` and import it here instead.
    const response = await fetch(guideFunctionUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Webhook-Secret': secretHeader,
      },
      body: JSON.stringify(payload),
    });

    if (!response.ok) {
      const body = await response.text();
      context.log.error('Guide function returned non‑200 response', body);
      context.res = { status: 502, body: { error: 'Failed to invoke guide function' } };
      return;
    }

    // Success – return a simple acknowledgement
    context.res = { status: 200, body: { status: 'processed' } };
  } catch (error) {
    context.log.error('Error processing after-payment request', error);
    context.res = { status: 500, body: { error: 'Internal server error' } };
  }
};
