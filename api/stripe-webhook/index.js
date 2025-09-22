const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

module.exports = async function (context, req) {
  const sig = req.headers['stripe-signature'];
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  if (!webhookSecret) {
    context.log.error('Missing STRIPE_WEBHOOK_SECRET');
    context.res = { status: 500, body: 'Server not configured' };
    return;
  }

  let event;
  try {
    const raw =
      req.rawBody || (typeof req.body === 'string' ? req.body : JSON.stringify(req.body || {}));
    event = stripe.webhooks.constructEvent(raw, sig, webhookSecret);
  } catch (err) {
    context.log.error('Stripe signature verification failed:', err.message);
    context.res = { status: 400, body: `Webhook Error: ${err.message}` };
    return;
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed':
        context.log('checkout.session.completed', event.data.object.id);
        break;
      case 'invoice.paid':
      case 'invoice.payment_succeeded':
        context.log('invoice paid', event.data.object.id);
        break;
      default:
        context.log('Unhandled event type', event.type);
    }
    context.res = { status: 200, body: 'ok' };
  } catch (err) {
    context.log.error('Handler error:', err);
    context.res = { status: 500, body: 'Internal error' };
  }
};
