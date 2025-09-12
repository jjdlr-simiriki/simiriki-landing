const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

module.exports = async function (context, req) {
  const signature = req.headers['stripe-signature'];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  if (!webhookSecret) {
    context.log.error('Missing STRIPE_WEBHOOK_SECRET environment variable');
    context.res = { status: 500, body: { error: 'Server misconfiguration' } };
    return;
  }

  let event;
  try {
    const raw = req.rawBody || (typeof req.body === 'string' ? req.body : JSON.stringify(req.body || {}));
    event = stripe.webhooks.constructEvent(raw, signature, webhookSecret);
  } catch (err) {
    context.log('Webhook signature verification failed.', err.message);
    context.res = { status: 400, body: `Webhook Error: ${err.message}` };
    return;
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object;
    context.log(`Checkout completed: ${session.id}`);
    // Optionally: trigger post-payment processing here
  }

  context.res = { status: 200, body: { received: true } };
};
