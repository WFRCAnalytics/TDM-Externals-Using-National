
RUN PGM=HIGHWAY  MSG='Creating External Lookup Table by using Freeflow Skims'
    FILEI  NETI     = 'input\USTM_NAT_Merged.net'

    FILEO  MATO     = 'skm_USTMExt.mtx', mo=1-3, name=time, distance, external, numext
    
    FILEO PRINTO[1] = "ExternalLookup.csv"
    FILEO PRINTO[2] = "ExternalNumIJPairs.csv"
    FILEO PRINTO[3] = "ExternalMoreThan1.csv"

    ;set HIGHWAY parameters
    ZONES   = 8976
    ZONEMSG = 10

    ARRAY PairsThroughExternals = 30


    PHASE=LINKREAD
        ;recalculate distance (long external links should not be included because it
        ;affects IXXI trip lengths)
        _DIST = LI.DISTANCE
        
        ;assign free flow time working variable
        LW.TIME_ADJ = LI.TIME_ADJ
        
    ENDPHASE

    
    ;build time minimized paths
    PHASE=ILOOP

        IF (I=1) ;Headers for each CSV

            PRINT PRINTO=1,
                CSV=T,
                LIST= "ODPair", "I", "J", "External", "Time", "Distance"

            PRINT PRINTO=2,
                CSV=T,
                LIST= "External", "NumIJPairs"

            PRINT PRINTO=3,
                CSV=T,
                LIST= "ODPair", "I", "J", "NumExt"

        ENDIF

        ;find time minimized paths and trace time and distance
        PATHLOAD CONSOLIDATE=T, PATH=LW.TIME_ADJ,          ;use adjusted time to find path
                mw[1]=PATHCOST, NOACCESS=90000,            ;zone-to-zone times
                mw[2]=PATHTRACE(li.DISTANCE), NOACCESS=0,  ;zone-to-zone distances of best time path
                mw[3]=PATHTRACE(li.USTM_EXT), NOACCESS=0,  ;a single link at external location has external number, so this matrix will return the external through which path goes
                mw[4]=PATHTRACE(li.EXT)     , NOACCESS=0   ;each "exernal" link as a 1 value in this field, so any sum >1 will mean path is through more than one external

        JLOOP

            IF (I>30 & J>30 & mw[1][J]<>90000); create external lookup table for IX, XI I-J pairs (less than 30 are externals, 90000 means no path found (Hawaii))

                _ONode  = LTRIM(STR(I, 6, 0))
                _DNode  = LTRIM(STR(J, 6, 0))
                _ODPair = _ONode + '_' + _DNode

                IF ((J>8775 & I<=8775) | (I>8775 & J<=8775)) ;(I-USTM, J-National) or (I-National, J-USTM)

                    IF (mw[4][J]=1) ;goes through only one external

                        PRINT PRINTO=1,
                            CSV=T,
                            LIST= _ODPair, I, J, mw[3][J], mw[1][J], mw[2][J]
                        
                        _externalnum = mw[3][J]
                        PairsThroughExternals[_externalnum] = PairsThroughExternals[_externalnum] + 1

                    ELSEIF (mw[4][J]>1) ;goes through more than one external

                        mw[3][J] = 0 ;set external value to zero, since value represents more than one external
                        PRINT PRINTO=3,
                            CSV=T,
                            LIST= _ODPair, I, J, mw[4][J]

                    ENDIF

                ELSE 

                    mw[3][J] = 0 ;set to zero for all non IX, XI Pairs

                ENDIF

            ELSE

                mw[3][J] = 0 ;set external value to zero for externals

            ENDIF

        ENDJLOOP

        IF (I=ZONES) ;at the end of jloop

            LOOP _iter=1, 30 ;export number of I-J pairs that go through each external

                PRINT PRINTO=2,
                    CSV=T,
                    LIST= _iter, PairsThroughExternals[_iter]

            ENDLOOP

        ENDIF

    ENDPHASE
ENDRUN
