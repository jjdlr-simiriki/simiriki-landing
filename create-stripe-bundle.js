/*
 * This utility script creates a product and price in Stripe for the
 * "Guía + Strategy Call" upsell bundle. Run it once with your Stripe
 * secret API key in the environment (e.g., `STRIPE_SECRET_KEY=sk_test_xxx node create-stripe-bundle.js`).
 * Adjust the product name, description, and price (in cents) as needed.
 */

const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

async function createBundle() {
  try {
    // Define the product details
    const product = await stripe.products.create({
      name: 'Guía + 30‑Min Strategy Call',
      description:
        'Bundle: Personalized automation guide plus a 30‑minute strategy call to review your automation pipeline.',
    });

    // Define the price (MXN 1,990 = 199000 cents)
    const price = await stripe.prices.create({
      unit_amount: 199000,
      currency: 'mxn',
      product: product.id,
      nickname: 'Guía + Call Bundle',
    });

    console.log('Upsell bundle created successfully');
    console.log('Product ID:', product.id);
    console.log('Price ID:', price.id);
  } catch (err) {
    console.error('Failed to create bundle:', err);
    process.exit(1);
  }
}

createBundle();
