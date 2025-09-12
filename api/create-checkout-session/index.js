const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

module.exports = async function (context, req) {
  try {
    const origin = (req.headers.origin || 'https://www.simiriki.com').replace(/\/+$/,'');
    const session = await stripe.checkout.sessions.create({
      mode: 'payment',
      line_items: [{ price: process.env.STRIPE_PRICE_ID, quantity: 1 }],
      success_url: `${origin}/?checkout=success`,
      cancel_url: `${origin}/?checkout=cancel`,
      automatic_tax: { enabled: true }
    });
    context.res = {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
      body: { id: session.id, url: session.url }
    };
  } catch (e) {
    context.res = { status: 500, body: { error: e.message } };
  }
};
