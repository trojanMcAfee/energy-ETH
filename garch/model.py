import numpy as np
import yfinance as yf
import scipy.optimize as spop
import json


ticker = 'ETH-USD'
start = '2020-01-01'
end = '2024-07-22'

#downloading data
prices = yf.download(ticker, start, end)['Close']

#calculating returns
returns = np.array(prices)[1:]/np.array(prices)[:-1] - 1

#starting parameter values - sample mean and variance
mean = np.average(returns)
var = np.std(returns)**2
def garch_mle(params):
    #specifying model parameters
    mu = params[0]
    omega = params[1]
    alpha = params[2]
    beta = params[3]
    #calculating long-run volatility
    long_run = (omega/(1 - alpha - beta))**(1/2)
    #calculating realised and conditional volatility
    resid = returns - mu
    realised = abs(resid)
    conditional = np.zeros(len(returns))
    conditional[0] =  long_run
    for t in range(1,len(returns)):
        conditional[t] = (omega + alpha*resid[t-1]**2 + beta*conditional[t-1]**2)**(1/2)
    #calculating log-likelihood
    likelihood = 1/((2*np.pi)**(1/2)*conditional)*np.exp(-realised**2/(2*conditional**2))
    log_likelihood = np.sum(np.log(likelihood))
    return -log_likelihood

#maximising log-likelihood
res = spop.minimize(garch_mle, [mean, var, 0, 0], method='Nelder-Mead')

#retrieving optimal parameters
params = res.x
mu = res.x[0]
omega = res.x[1]
alpha = res.x[2]
beta = res.x[3]
log_likelihood = -float(res.fun)

#calculating realised and conditional volatility for optimal parameters
long_run = (omega/(1 - alpha - beta))**(1/2)
resid = returns - mu
realised = abs(resid)
conditional = np.zeros(len(returns))
conditional[0] =  long_run
for t in range(1,len(returns)):
    conditional[t] = (omega + alpha*resid[t-1]**2 + beta*conditional[t-1]**2)**(1/2)


garch_params_original = {
    "last_conditional": conditional[-1],
    "last_residual": resid[-1],
    "mu": mu,
    "omega": omega,
    "alpha": alpha,
    "beta": beta 
}
    
garch_params_exponential = {
    "last_conditional": int(conditional[-1] * 10 ** 18),
    "last_residual": int(resid[-1] * 10 ** 18),
    "mu": int(mu * 10 ** 18),
    "omega": int(omega * 10 ** 18),
    "alpha": int(alpha * 10 ** 18),
    "beta": int(beta * 10 ** 18)
}

with open('./garch/params/original.json', 'w') as file:
    json.dump(garch_params_original, file, indent=4)

with open('./garch/params/exponential.json', 'w') as file:
    json.dump(garch_params_exponential, file, indent=4)