RUN PGM=NETWORK MSG='Scan Node Numbering Schemes for Subareas'
FILEI LINKI[1] = "BY_2019.NET"
FILEI LINKI[2] = "Nation_NAD_2017-09-11_NoUtah.net"


FILEO PRINTO[1] = "_Node_Number_Schemes.csv"
FILEO PRINTO[2] = "_MaxUsedZones_forPython.txt"

    
    ;USTM
    PHASE=INPUT FILEI=ni.1
        ;count total nodes
        _USTM_Tot_Cnt = _USTM_Tot_Cnt + 1
        
        ;count TAZ and find max TAZ number
        if (SUB_TYPE=1)
            _USTM_TAZ_Cnt = _USTM_TAZ_Cnt + 1
            _USTM_TAZ_MAX = MAX(_USTM_TAZ_MAX, N)
        endif
        
        ;count externals and find min/max external numbers
        if (SUB_TYPE=2)
            _USTM_EXT_Cnt = _USTM_EXT_Cnt + 1
            _USTM_EXT_Max = MAX(_USTM_EXT_Max, N)
            
            if (_USTM_EXT_Min = 0)
                _USTM_EXT_Min = N
            else
                _USTM_EXT_Min = Min(_USTM_EXT_Min, N)
            endif
        endif
        
        ;count highway nodes
        if (SUB_TYPE=0,3)  _USTM_HWY_Cnt = _USTM_HWY_Cnt  + 1
    ENDPHASE
    
    
    ;NATIONAL
    PHASE=INPUT FILEI=ni.2
        ;count total nodes
        _NAT_Tot_Cnt = _NAT_Tot_Cnt + 1
        
        ;count TAZ and find max TAZ number
        if (N<=215)
            _NAT_TAZ_Cnt = _NAT_TAZ_Cnt + 1
            _NAT_TAZ_MAX = MAX(_NAT_TAZ_MAX, N)
        ;count externals and find min/max external numbers
        elseif (n<=1000)
            _NAT_EXT_Cnt = _USTM_EXT_Cnt + 1
            _NAT_EXT_MAX = MAX(_NAT_EXT_MAX, N)
            
            if (_NAT_EXT_MIN = 0)
                _NAT_EXT_MIN = N
            else
                _NAT_EXT_MIN = Min(_NAT_EXT_MIN, N)
            endif
        ;count highway nodes
        else
            _NAT_HWY_Cnt = _NAT_HWY_Cnt  + 1
        endif
    ENDPHASE
    
    ;Log variables for further use
    PHASE=SUMMARY
        
        _RS_MaxExternal = 30

        _NEW_ZONE = _RS_MaxExternal  +    ;USTM external range=1-30
                    _USTM_TAZ_Cnt    +
                    _NAT_TAZ_Cnt
        
        _USTM_Highest  = MAX(_USTM_TAZ_MAX, _USTM_EXT_MAX)
        _NAT_Highest   = MAX(_NAT_TAZ_MAX , _NAT_EXT_MAX )
        
        
        ;set new TAZ variables for print file
        _USTM_TAZ_first  = _RS_MaxExternal + 1
        _USTM_TAZ_last   = _RS_MaxExternal + _USTM_TAZ_Cnt
        
        _NAT_TAZ_first   = _USTM_TAZ_last  + 1
        _NAT_TAZ_last    = _USTM_TAZ_last  + _NAT_TAZ_Cnt
        
        ;set new Highway variables for print file
        _USTM_Hwy_first  = 10000
        _USTM_Hwy_last   = _USTM_HWY_first + _USTM_HWY_Cnt
        
        _NAT_Hwy_first   = 80000
        _NAT_Hwy_last    = _NAT_HWY_first  + _NAT_HWY_Cnt

        ;print variables to output text file
        PRINT PRINTO=1,
            CSV=T,
            FORM=10.0,
            LIST='Highwway Network Node Schemes',
                 '\n',
                 '\nNew Statewide Node Scheme',
                 '\nExternal Range', RS_MaxExternal,
                 '\nFirst TAZ', _USTM_TAZ_first,
                 '\nMax TAZ', _NEW_ZONE,
                 '\n ',            'TAZ Low',       'TAZ High',      'Hwy Low',         'Hwy High',
                 '\nUSTM Nodes',  _USTM_TAZ_first, _USTM_TAZ_last, _USTM_Hwy_first, _USTM_Hwy_last,
                 '\nNAT Nodes' ,  _NAT_TAZ_first , _NAT_TAZ_last , _NAT_Hwy_first , _NAT_Hwy_last,
                 '\n',
                 '\n',
                 '\nPrevious Network Node Schemes',
                 '\n ',       'Max Int TAZ',   'Max Ext',       'UsedZones',     'TAZ Count',     'Ext Count',     'Hwy Count',     'Total Count',
                 '\nUSTM',   _USTM_TAZ_MAX,  _USTM_EXT_Max,  _USTM_Highest,  _USTM_TAZ_Cnt,  _USTM_EXT_Cnt,  _USTM_HWY_Cnt,  _USTM_Tot_Cnt,
                 '\nNAT' ,   _NAT_TAZ_MAX ,  _NAT_EXT_Max ,  _NAT_Highest ,  _NAT_TAZ_Cnt ,  _NAT_EXT_Cnt ,  _NAT_HWY_Cnt ,  _NAT_Tot_Cnt,
                 '\n',
                 '\n'
        
        
        ;print variables to output text file
        PRINT PRINTO=2,
            FORM=6.0,
            LIST='# 03_Update_Link_Node.py  script input',
                 '\nUsedZones =', _NEW_ZONE
        
        
        ;log variables to .VAR file
        LOG VAR = _USTM_Highest
        LOG VAR = _USTM_TAZ_MAX
        LOG VAR = _USTM_EXT_Min
        LOG VAR = _USTM_EXT_Max
        LOG VAR = _USTM_TAZ_Cnt
        LOG VAR = _USTM_EXT_Cnt
        LOG VAR = _USTM_HWY_Cnt
        
        LOG VAR = _NAT_Highest
        LOG VAR = _NAT_TAZ_MAX
        LOG VAR = _NAT_EXT_Min
        LOG VAR = _NAT_EXT_Max
        LOG VAR = _NAT_TAZ_Cnt
        LOG VAR = _NAT_EXT_Cnt
        LOG VAR = _NAT_HWY_Cnt
        
        LOG VAR = _NEW_ZONE
        
    ENDPHASE

ENDRUN


RUN PGM=NETWORK MSG='Combine Networks & Print Equivalencies'
FILEI LINKI[1] = "BY_2019.net"
FILEI LINKI[2] = "Nation_NAD_2017-09-11_NoUtah.net"

FILEO NETO = "USTM_NAT_Merged.NET",
    INCLUDE=A,
            B,
            DISTANCE,
            FT,
            SPEED,
            TIME,
            USTM_NAT

FILEO LINKO = "USTM_NAT_Merged_Link.dbf",
    INCLUDE=A,
            B,
            DISTANCE,
            FT,
            SPEED,
            TIME,
            USTM_NAT
    

FILEO NODEO = "USTM_NAT_Merged_Node.dbf",
    INCLUDE=N,
            X,
            Y


FILEO PRINTO[1] = "NodeEquiv_USTM.csv"
FILEO PRINTO[2] = "NodeEquiv_NAT.csv"

FILEO PRINTO[3] = "NodeEquiv_All_USTM.csv"
FILEO PRINTO[4] = "Joint_Nodes.csv"
FILEO PRINTO[5] = "External_Links.csv"

    
    ZONES = 9999
    
    
    ;define arrays
    ARRAY USTM_NewNode = 9999999,
           NAT_NewNode = 9999999,
              PrevNode = 9999999
    
    
    ;merge input networks
    MERGE RECORD = T
    
    
    ;pre-process node data ---------------------------------------------------------------
    ;USTM
    PHASE=INPUT FILEI=ni.1
        ;Print out the headers for all equivalency files
        if (_SAEquivHeader=0)
            _SAEquivHeader = 1
            PRINT PRINTO=1, CSV=T, FORM=10.0, LIST = ';PrevNode','New_Node','Type'
            PRINT PRINTO=2, CSV=T, FORM=10.0, LIST = ';PrevNode','New_Node','Type'
        endif
        
        ;number USTM/USTM externals
        if (SUB_TYPE=2)            
            _USTM_EXT_Idx = _USTM_EXT_Idx + 1
            
            ;begin USTM numbering scheme with USTM externals
            USTM_NewNode[N] = _USTM_EXT_Idx
            
            PRINT PRINTO=1, CSV=T, FORM=10.0, LIST=N, USTM_NewNode[N], 'External'
        endif 
        
        _RS_MaxExternal = 30

        ;number USTM TAZ
        if (SUB_TYPE=1)
            _USTM_TAZ_Idx = _USTM_TAZ_Idx + 1
            
            ;after externals, number USTM TAZ in order of USTM TAZ
            _NewTAZ_USTM = _RS_MaxExternal +
                            _USTM_TAZ_Idx
            
            USTM_NewNode[N] = _NewTAZ_USTM
            
            PRINT PRINTO=1, CSV=T, FORM=10.0, LIST=N, USTM_NewNode[N], 'TAZ'
        endif
        
        ;number USTM highway nodes
        if (SUB_TYPE=0,3)
            _USTM_HWY_Idx = _USTM_HWY_Idx + 1
            
            ;start Rrual highway number scheme at 10,000
            USTM_NewNode[N] = 10000-1 + _USTM_HWY_Idx
            
            PRINT PRINTO=1, CSV=T, FORM=10.0, LIST=N, USTM_NewNode[N], 'Highway'
        endif
        
        ;set N to be new node number and store original node number in PrevNode array
        _Temp           = USTM_NewNode[N]    ;set temp variable to new node number
        PrevNode[_Temp] = N                   ;store original node number into array at index of new node
        N               = _Temp               ;set N to new node number
        
    ENDPHASE
    
    
    ;NAT
    PHASE=INPUT FILEI=ni.2
        ;number NAT TAZ & externals
        if (N<=215)            
            _NAT_TAZ_Idx = _NAT_TAZ_Idx + 1
            
            ;after USTM, USTM TAZ numbering scheme uses NAT TAZ and externals
            _NewTAZ_NAT = _NewTAZ_USTM +
                         _NAT_TAZ_Idx
            
            NAT_NewNode[N] = _NewTAZ_NAT
            
            PRINT PRINTO=2, CSV=T, FORM=10.0, LIST=N, NAT_NewNode[N], 'TAZ'
        
        ;number NAT highway nodes
        else
            _NAT_HWY_Idx = _NAT_HWY_Idx + 1
            
            ;start NAT highway number scheme at 80,000
            NAT_NewNode[N] = 80000-1 + 
                            _NAT_HWY_Idx
            
            if (SUB_TYPE=2)    PRINT PRINTO=2, CSV=T, FORM=10.0, LIST=N, NAT_NewNode[N], 'External'
            if (SUB_TYPE=0,3)  PRINT PRINTO=2, CSV=T, FORM=10.0, LIST=N, NAT_NewNode[N], 'Highway'
            
            ;reset SUB_TYPE for USTM-National network subarea extraction
            SUB_TYPE=0
        endif
        
        ;set N to be new node number and store original node number in PrevNode array
        _Temp           = NAT_NewNode[N]
        PrevNode[_Temp] = N                               ;Restore original node number N to PrevNode field
        N               = NAT_NewNode[N]                   ;Update node number
        
    ENDPHASE
        
    
    ;pre-process link data ---------------------------------------------------------------
    ;USTM  
    PHASE=INPUT FILEI = li.1
        A = USTM_NewNode[A]
        B = USTM_NewNode[B]
    ENDPHASE
    
    ;NAT  
    PHASE=INPUT FILEI = li.2
        A = NAT_NewNode[A]
        B = NAT_NewNode[B]
    ENDPHASE
    
    
    ;process nodes -----------------------------------------------------------------------
    PHASE=NODEMERGE
        ;update JOINT_NODE
        if (JOINT_NODE>0)
            OLD_JTNODE = JOINT_NODE
            
            if (JOINT_TYPE=1)
                JOINT_NODE = NAT_NewNode[JOINT_NODE]
            endif
        endif
        
        
        ;print new node number scheme equivalency
        if (_NewEquivHeader=0)
            _NewEquivHeader=1
            PRINT PRINTO=3, CSV=T, FORM=10.0, LIST = ';New_Node','PrevNode','Type', 'Source'
        endif
        
        ;USTM
        if (USTM_NAT='USTM')
            if (SUB_TYPE=1)
                PRINT PRINTO=3, CSV=T, FORM=10.0, LIST=N, PrevNode[N], 'TAZ', 'USTM'
            elseif (SUB_TYPE=2)
                PRINT PRINTO=3, CSV=T, FORM=10.0, LIST=N, PrevNode[N], 'External', 'USTM'
            else
                PRINT PRINTO=3, CSV=T, FORM=10.0, LIST=N, PrevNode[N], 'Highway', 'USTM'
            endif
        
        ;NAT
        elseif (USTM_NAT='NAT')
            if (SUB_TYPE=1)
                PRINT PRINTO=3, CSV=T, FORM=10.0, LIST=N, PrevNode[N], 'TAZ', 'NAT'
            elseif (SUB_TYPE=2)
                PRINT PRINTO=3, CSV=T, FORM=10.0, LIST=N, PrevNode[N], 'External', 'NAT'
            else
                PRINT PRINTO=3, CSV=T, FORM=10.0, LIST=N, PrevNode[N], 'Highway', 'NAT'
            endif
        endif
        
        ;print joint node temp file
        if (_JointNodeHeader=0)
            _JointNodeHeader=1
            PRINT PRINTO=4, CSV=T, FORM=10.0, LIST=';N', 'X', 'Y', 'EXTERNAL', 'JOINT_TYPE', 'JOINT_NODE', 'PrevNode'
        endif
        
        if (EXTERNAL>0 | JOINT_TYPE>0)
            PRINT PRINTO=4, CSV=T, FORM=10.0, LIST=N, X(15.7), Y(15.7), EXTERNAL, JOINT_TYPE, JOINT_NODE, PrevNode[N]
        endif
        
        ;set network variables
        OLD_NODE  = 0              ;place holder for national-USTM merged network
        SUBAREA_N = PrevNode[N]    ;store original subarea node
    ENDPHASE
    
    
    ;process links -----------------------------------------------------------------------
    PHASE=LINKMERGE
        
        ;print external link temp file
        if (_ExtLinkeader=0)
            _ExtLinkeader=1
            PRINT PRINTO=5, CSV=T, FORM=10.0, LIST=';A', 'B', 'EXTERNAL', 'SUB_TYPE_L'
        endif
        
        if (A.EXTERNAL>1 | B.EXTERNAL>1)
            _External = MAX(A.EXTERNAL, B.EXTERNAL)
            
            PRINT PRINTO=5, CSV=T, FORM=10.0, LIST=A, B, _External, SUB_TYPE_L
        endif

        if (USTM_NAT='USTM')
            FT       = li.1.FT
            DISTANCE = li.1.DISTANCE
            TIME     = li.1.FF_TIME
            SPEED    = li.1.FF_SPD
        elseif (USTM_NAT='NAT')
            FT       = li.2.FCLASS
            DISTANCE = li.2.MILES
            TIME     = li.2.TIME
            SPEED    = li.2.SPEED07
        endif

    ENDPHASE

ENDRUN
