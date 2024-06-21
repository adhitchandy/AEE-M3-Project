@defcomp extension begin
    DAMAGES = Variable(index=[time])    # Damages (trillions 2010 USD per year)
    DAMFRAC = Variable(index=[time])    # Damages (fraction of gross output)
    ADAPT = Variable(index=[time])      # Adaptation effectiveness
    GROSSDAM = Variable(index=[time])   # Gross damages (trillions 2010 USD per year)
    RESIDUALDAM = Variable(index=[time])# Residual damages (trillions 2010 USD per year)
    PROTECTIONCOST = Variable(index=[time]) # Protection costs (trillions 2010 USD per year)
    SAD = Variable(index=[time])        # Stock Adaptation (trillions 2010 USD per year)
    SADC = Variable(index=[time])       # Cumulative Stock Adaptation (trillions 2010 USD)
    FAD = Variable(index=[time])        # Flow Adaptation trillion 2010 dollars
    IA = Variable(index=[time])         # Investment in stock adaptation per period in trillion of dollars

    TATM = Parameter(index=[time])      # Increase temperature of atmosphere (degrees C from 1900)
    YGROSS = Parameter(index=[time])    # Gross world product GROSS before abatement and damages (trillions 2010 USD per year)
    a1 = Parameter()                    # Damage coefficient
    a2 = Parameter()                    # Damage quadratic term (a2 > 0)
    a3 = Parameter()                    # Damage exponent (a3 > 1)
    delta1 = Parameter()                # Discount factor of stock Adaptation
    l1 = Parameter(index=[time])        # Effectiveness coefficient of flow adaptation
    l2 = Parameter()                    # Effectiveness coefficient of cumulative stock adaptation
    flowshare = Parameter(index=[time]) #share of budget allowed for flow adaptation
    B = Parameter(index = [time])       #total adaptation budget per time period

    function run_timestep(p, v, d, t)
        # Define GROSSDAM
        v.GROSSDAM[t] = (p.a1 * p.TATM[t] + p.a2 * p.TATM[t] ^ p.a3) * p.YGROSS[t]

        #Define IA
        v.IA[t] = (1 - p.flowshare[t]) * p.B[t]
        
        # Define SAD (Stock Adaptation for the current period)
        v.SAD[t] = v.IA[t]
        
        # Calculate cumulative stock adaptation (SADC)
        if t == d.time[1]
            v.SADC[t] = v.IA[t]
        else
            v.SADC[t] = (1 - p.delta1) * v.SADC[t-1] + v.IA[t]
        end   

        #Define FAD
        v.FAD[t] = p.flowshare[t] * p.B[t]

        # Define ADAPT
        v.ADAPT[t] = p.l1[t] * v.FAD[t] + p.l2 * v.SADC[t]
        
        # Define RESIDUALDAM
        v.RESIDUALDAM[t] = v.GROSSDAM[t] - v.ADAPT[t]

        # Define PROTECTIONCOST
        v.PROTECTIONCOST[t] = v.FAD[t] + v.IA[t]

        # Define DAMFRAC
        v.DAMFRAC[t] = (v.RESIDUALDAM[t] / p.YGROSS[t]) + (v.PROTECTIONCOST[t] / p.YGROSS[t])

        # Define DAMAGES
        v.DAMAGES[t] = p.YGROSS[t] * v.DAMFRAC[t]
    end
end
