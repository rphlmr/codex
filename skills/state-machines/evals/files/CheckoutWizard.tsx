import { useEffect, useState } from "react";

import { submitPayment, validateAddress } from "./api";
import { AddressStep, Confirmation, ErrorBanner, PaymentStep, Spinner } from "./ui";

type Step = 1 | 2 | 3;

export function CheckoutWizard({ orderId }: { orderId: string }) {
  const [step, setStep] = useState<Step>(1);
  const [address, setAddress] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [isError, setIsError] = useState(false);
  const [retryCount, setRetryCount] = useState(0);

  useEffect(() => {
    if (retryCount > 0) {
      setIsLoading(true);
    }
  }, [retryCount]);

  async function handleAddressNext() {
    setIsLoading(true);

    try {
      await validateAddress(address);
      setStep(2);
    } catch {
      setIsError(true);
    }

    setIsLoading(false);
  }

  async function handlePay() {
    setIsSubmitting(true);
    setIsError(false);

    try {
      await submitPayment(orderId);
      setStep(3);
    } catch {
      setIsError(true);
      setRetryCount((count) => count + 1);
    } finally {
      setIsSubmitting(false);
    }
  }

  function handleCancel() {
    setStep(1);
    setIsError(false);
  }

  return (
    <div>
      {(isLoading || isSubmitting) && <Spinner />}
      {isError && <ErrorBanner onRetry={handlePay} />}
      {step === 1 && (
        <AddressStep value={address} onChange={setAddress} onNext={handleAddressNext} />
      )}
      {step === 2 && <PaymentStep onPay={handlePay} onCancel={handleCancel} />}
      {step === 3 && <Confirmation orderId={orderId} />}
    </div>
  );
}
