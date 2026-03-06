/**
 * Money/Amount Validation Helpers
 */

export function parseUSD(n: any): string {
  const num = Number(n);
  if (!isFinite(num) || num <= 0) {
    throw new Error('Invalid USD amount');
  }
  return (Math.round(num * 100) / 100).toFixed(2);
}

export function parseUSDT(n: any): string {
  const num = Number(n);
  if (!isFinite(num) || num <= 0) {
    throw new Error('Invalid USDT amount');
  }
  return (Math.round(num * 1000000) / 1000000).toFixed(6);
}

export function calcWithdrawalFee(amount: string, pct: number): string {
  const num = Number(amount);
  const fee = num * (pct / 100);
  return amount.includes('.') && amount.split('.')[1].length === 6 
    ? fee.toFixed(6) 
    : fee.toFixed(2);
}

export function safeNumber(n: any): number {
  const num = Number(n);
  if (!isFinite(num)) {
    throw new Error('Invalid number');
  }
  return num;
}
