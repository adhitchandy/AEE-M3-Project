@defcomp newdamages begin
    DAMAGES = Variable(index=[time])    #Damages (trillions 2010 USD per year)
    DAMFRAC = Variable(index=[time])    #Damages (fraction of gross output)
    GROSSDAM = Variable(index=[time])   # Gross damages (trillions 2010 USD per year)
    RESIDUALDAM = Variable(index=[time]) # Residual damages (trillions 2010 USD per year)
    PROTECTIONCOST = Variable(index=[time]) # Protection costs (trillions 2010 USD per year)


    TATM    = Parameter(index=[time])   #Increase temperature of atmosphere (degrees C from 1900)
    YGROSS  = Parameter(index=[time])   #Gross world product GROSS before abatement and damages (trillions 2010 USD per year)
    a1      = Parameter()               #Damage coefficient
    a2      = Parameter()               #Damage quadratic term (a2>0)
    a3      = Parameter()               #Damage exponent (a3>1)
    Pt      = Parameter(index=[time])   #Level of protection (0 ≤ Pt ≤ 1)
    g1      = Parameter()               #Protection coefficient (g1>0)
    g2      = Parameter()               #Protection exponent (g2>1)


    function run_timestep(p, v, d, t)
        #Define GROSSDAM
        v.GROSSDAM[t] = (p.a1 * p.TATM[t] + p.a2 * p.TATM[t] ^ p.a3)*p.YGROSS[t]

        #Define RESIDUALDAM
        v.RESIDUALDAM[t] = v.GROSSDAM[t] * (1-p.Pt[t])
        
        #Define PROTECTIONCOST
        v.PROTECTIONCOST[t] = (p.g1 * p.Pt[t] ^ p.g2)*p.YGROSS[t]
        
        #Define function for DAMFRAC
        v.DAMFRAC[t] = (v.RESIDUALDAM[t]/p.YGROSS[t]) + (v.PROTECTIONCOST[t]/p.YGROSS[t])
        
        #Define function for DAMAGES
            v.DAMAGES[t] = p.YGROSS[t] * v.DAMFRAC[t]
         end
    end