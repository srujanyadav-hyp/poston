# Payment Gateway Setup Guide (PhonePe PG)

Follow these steps to set up the professional payment infrastructure for the Poston App. Using a Payment Gateway ensures 100% transaction success and builds trust with users.

---

### Phase 1: Document Preparation
Before starting, please ensure you have digital copies (PDF or high-quality JPEG) of the following:

1.  **Business Identity**: PAN Card of the Business (or individual PAN for Sole Proprietorship).
2.  **Address Proof**: GST Certificate OR Shop & Establishment License OR Rental Agreement.
3.  **Bank Verification**: A cancelled cheque or the first page of the Bank Passbook.
    *   *Important: The bank account name must match the Business/PAN name.*
4.  **Aadhaar Card**: Of the authorized owner.

---

### Phase 2: Online Registration
1.  **Visit the Portal**: Go to the [PhonePe Payment Gateway Registration Page](https://www.phonepe.com/business-solutions/payment-gateway/register/).
2.  **Submit Interest**: Fill in your Mobile Number, Email, and Business Name.
3.  **PhonePe Call**: A representative from PhonePe will usually call you within 24 hours to guide you through the digital KYC.
4.  **KYC Submission**: Upload the documents prepared in Phase 1 through the link they provide.
5.  **Activation**: Verification usually takes **2 to 5 business days**. You will receive an email once your account is "Live".

---

### Phase 3: Technical Handover
Once your account is activated, please log in to your **PhonePe Business Dashboard** and provide the following technical details to the development team:

1.  **Merchant ID (MID)**: Usually looks like `PGCHECKOUT...`
2.  **Salt Key**: A long secure string (e.g., `34e56...`).
3.  **Salt Index**: A single digit number (usually `1`).

*Note: These keys are like a password for your payments. Please share them only via a secure channel.*

---

### Why we are using this method?
*   **0% Commission on UPI**: PhonePe currently offers zero commission on UPI transactions.
*   **No Security Blocks**: Unlike standard UPI links, this professional gateway is trusted by all Indian banks (IndusInd, SBI, HDFC, etc.).
*   **Automatic Reconciliation**: You can track every payment and refund directly from your dashboard.

---
*Poston App Development Team*
