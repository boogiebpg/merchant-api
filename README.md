# Merchant Test
A couple endpoints to work with transactions, merchant admin panel.

### Structure and behavior description
1. There are merchant and admin user roles
2. Merchants has many payment transactions of different types
3. Transactions are related (belongs_to)
We can also have follow/referenced transactions that refer/depend to/on
the initial transaction.
The possible chains are:
Authorize Transaction -> Charge Transaction -> Refund Transaction
Authorize Transaction -> Reversal Transaction
Only approved or refunded transactions can be referenced,
otherwise the submitted transaction will be created with status error

### Components
1. Rake task to import new merchants and admins from CSV
2. A background Job for deleting transactions older than an hour (cron job)
3. Accepts payments using XML/ JSON API (single point POST request)
Include API authentication layer (using JWT tokens)
No transactions can be submitted unless the merchant is in active state

### Presentation:
1. Display, edit, destroy merchants
2. Display transactions
