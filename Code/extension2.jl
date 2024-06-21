@defcomp extension begin
    DAMAGES = Variable(index=[time])    # Damages (trillions 2010 USD per year)
    DAMFRAC = Variable(index=[time])    # Damages (fraction of gross output)
    ADAPT = Variable(index=[time])      # Adaptation effectiveness
    GROSSDAM = Variable(index=[time])   # Gross damages (trillions 2010 USD per year)
    RESIDUALDAM = Variable(index=[time])# Residual damages (trillions 2010 USD per year)
    PROTECTIONCOST = Variable(index=[time]) # Protection costs (trillions 2010 USD per year)
    NETY = Variable(index=[time])       # Net GWP after reducing the PROTECTIONCOST (trillions 2010 USD per year)
    SAD = Variable(index=[time])        # Stock Adaptation (trillions 2010 USD per year)
    SADC = Variable(index=[time])       # Cumulative Stock Adaptation (trillions 2010 USD)
    B = Variable(index=[time])          #Cumulative benefit from stock adaptation at time t

    TATM = Parameter(index=[time])      # Increase temperature of atmosphere (degrees C from 1900)
    YGROSS = Parameter(index=[time])    # Gross world product GROSS before abatement and damages (trillions 2010 USD per year)
    a1 = Parameter()                    # Damage coefficient
    a2 = Parameter()                    # Damage quadratic term (a2 > 0)
    a3 = Parameter()                    # Damage exponent (a3 > 1)
    IA = Parameter(index=[time])        # Investment in Adaptation (in trillion dollars)
    delta1 = Parameter()                # Discount factor of stock Adaptation
    l1 = Parameter(index=[time])             #effectiveness of FAD
    r = Parameter()                     # Effectiveness coefficient of cumulative stock adaptation
    FAD = Parameter(index=[time])       # Flow adaptation investment per period in trillions of dollars

    function run_timestep(p, v, d, t)
        # Define GROSSDAM in trillion dollars
        v.GROSSDAM[t] = (p.a1 * p.TATM[t] + p.a2 * p.TATM[t] ^ p.a3) * p.YGROSS[t]
        
        # Define SAD (Stock Adaptation for the current period) in trillion dollars
        v.SAD[t] = p.IA[t]
        
        # Calculate cumulative stock adaptation (SADC) in trillion dollars
        if t == d.time[1]
            v.SADC[t] = p.IA[t]
        else
            v.SADC[t] = (1 - p.delta1) * v.SADC[t-1] + p.IA[t]
        end   
        #Define benefit in trillion dollars
        v.B[t] = v.SADC[t] * p.r 

        # Define ADAPT / benefit at period t from both flow adaptation and stock adaptation in trillion dollars
        v.ADAPT[t] = (p.l1[t] * p.FAD[t]) + v.B[t]
        
        # Define RESIDUALDAM in trillion dollars
        v.RESIDUALDAM[t] = v.GROSSDAM[t] - v.ADAPT[t]

        # Define PROTECTIONCOST
        v.PROTECTIONCOST[t] = p.FAD[t] * 2

        # Define DAMFRAC
        v.DAMFRAC[t] = (v.RESIDUALDAM[t] / p.YGROSS[t]) + (v.PROTECTIONCOST[t] / p.YGROSS[t])

        # Define NETY
        v.NETY[t] = p.YGROSS[t] - (p.YGROSS[t] * v.DAMFRAC[t])

        # Define DAMAGES
        v.DAMAGES[t] = p.YGROSS[t] * v.DAMFRAC[t]
    end
end
