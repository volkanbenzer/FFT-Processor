`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 24.03.2025 20:28:18
// Design Name: 
// Module Name: Serial_Interface
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Serial_Interface
#( parameter log2FFTSize_Max = 4'd10,
   parameter log2FFTSize_BitSize = 3'd4
) 
(
    input clk_InputPin, reset_InputPin,
    
    input communicationType_InputPin, 
       
    input UART_Rx_InputPin,
    
    output UART_Tx_OutputPin,
    
    output reg startFFT_OutputPin,
    
    output reg [log2FFTSize_BitSize - 1 : 0] log2FFTSize_OutputPort,
     
    output reg [log2FFTSize_Max - 1 : 0] addRAMSampleSineW_OutputPort,
    output reg [15:0] dataInRAMSampleSineW_OutputPort,
    input [15:0] dataOutRAMSampleSineW_InputPort,       
    output reg csRAMSample_OutputPin, csRAMSineW_OutputPin, weRAMSampleSineW_OutputPin, oeRAMSampleSineW_OutputPin,
    
    output reg [log2FFTSize_Max - 1 : 0] addRAMdB_OutputPort,
    input signed [15:0] dataOutRAMdB_InputPort,
    output reg cs_RAMdB_OutputPin, oe_RAMdB_OutputPin,
	
    input bitReversalBusy_InputPin,
    input butterflyBusy_InputPin,
    input dBCalculatorBusy_InputPin,    
    input finishFFT_InputPin

);

    localparam N_WAVE = 1024;      /* full length of Sinewave[] */
    localparam LOG2_N_WAVE = 10;   /* log2(N_WAVE) */

    localparam SAMPLE_DATA_CDM = 8'h10;
    localparam SINEWAVE_DATA_CMD = 8'h20;
    
    localparam GET_SAMPLE_RAM_CDM = 8'h50;
    localparam GET_SINEWAVE_RAM_CMD = 8'h60;       
    
    localparam IS_RAM_BUSY_CMD = 8'h80;
    localparam START_FFT_CMD = 8'h90;

    localparam WRITE_RAM_STATE = 8'h10;
    localparam START_FFT_STATE = 8'h20;
	 
	wire UART_RxRdyOut_Wire;
	reg UART_RdyClr_Wire;
	wire [7:0] UART_Dout_Wire;
    
    wire wr_en, tx_busy;
    
        
    reg [7:0] stateCnt, transmitStateCnt;
        
    reg [15:0] recvCmd;
    
    reg [log2FFTSize_Max - 1 : 0] FFTSize; 
    
    reg [15:0] recvData16, transmitData16;
    reg [15:0] recvCount;
    reg byteCount, txByteCount;
    reg [15:0] dataLenght, txDataCount, txDataTotal;
    reg [7:0] cmd;
    reg [7:0] UART_TxReg;
    
    reg [log2FFTSize_BitSize - 1 : 0] log2FFTSize_Register;
    
    reg UartTxEn_reg; 
    
    UART uart_uut(.reset_InputPin(reset_InputPin), .clk_InputPin(clk_InputPin), 
    .rx_InputPin(UART_Rx_InputPin), .rxReady_OutputPin(UART_RxRdyOut_Wire), .rxReadyClr_InputPin(UART_RdyClr_Wire), .rxDataOut_OutputPort(UART_Dout_Wire),
    .tx_OutputPin(UART_Tx_OutputPin), .txWrEn_InputPin(UartTxEn_reg), .txBusy_OutputPin(tx_busy), .txDataIn_InputPort(UART_TxReg)
    );
    
    //assign dataOutputPort = UART_RxRdyOut_Wire ? UART_Dout_Wire : 8'hz;
    //assign dataReady_OutputPin = UART_RxRdyOut_Wire;
    //assign dataRdyClear_OutputPin = UART_RdyClr_Wire;
    
    always@(negedge clk_InputPin)
    begin
        if(reset_InputPin == 0)
        begin 
            transmitStateCnt <= 0;            
            UartTxEn_reg <=0;
        end
        else       
            case(transmitStateCnt)                    
                0:begin
                    if(finishFFT_InputPin & communicationType_InputPin)
                    begin
                        transmitStateCnt <= transmitStateCnt + 1;                        
                        txDataTotal <= ((16'h01 << log2FFTSize_Register) >> 1);
                        txDataCount <= 0;                        
                    end 
                    else
                        UartTxEn_reg <=0;
                    
                end
                
                1:begin
                    if(dBCalculatorBusy_InputPin == 0)
                    begin
                        transmitStateCnt <= transmitStateCnt + 1;  
                        cs_RAMdB_OutputPin <= 1;
                        oe_RAMdB_OutputPin <= 1;
                    end  
                end
                
                2:begin
                    addRAMdB_OutputPort <= txDataCount; 
                    transmitStateCnt <= transmitStateCnt + 1;                     
                end 
                
                3:begin
                    //transmitData16 <= dataOutRAMdB_InputPort; bunu yapamadığı için bekleme yapıyoruz 
                    //sorun olmazsa UART_TxReg <= dataOutRAMdB_InputPort[15:8] kullanmayı dene
                    //register kullanmamış olursun hem
                    transmitStateCnt <= transmitStateCnt + 1;
                end
                
                4:begin
                    transmitData16 <= dataOutRAMdB_InputPort; 
                    txByteCount <= 0;
                    transmitStateCnt <= transmitStateCnt + 1;
                end
                

                
                5:begin
                    if(txDataTotal == txDataCount)
                        transmitStateCnt <= 9;
                    else
                    begin
                        if(tx_busy == 0)
                        begin
                            if(txByteCount == 0)                            
                                UART_TxReg <= transmitData16[15:8];
                            else
                                UART_TxReg <= transmitData16[7:0];
                                
                            transmitStateCnt <= transmitStateCnt + 1;    
                        end 
                    end
                end
                
                6: begin
                    UartTxEn_reg <= 1;
                    transmitStateCnt <= transmitStateCnt + 1;
                end 
                
                7:begin
                    if(tx_busy == 1)
                    begin
                        UartTxEn_reg <= 0;
                        
                        if(txByteCount == 0)
                        begin
                            txByteCount <= 1;
                            transmitStateCnt <= 5;
                        end
                        else
                        begin
                            txDataCount <= txDataCount + 1;
                            transmitStateCnt <= 2;
                        end                                            
                    end
                end
                                
                9:begin
                    cs_RAMdB_OutputPin <= 0;
                    oe_RAMdB_OutputPin <= 0; 
                   
                    if(finishFFT_InputPin == 0)
                        transmitStateCnt <= 0;
                     
                end
            endcase        
    end

    
    always@(negedge clk_InputPin)
    begin
        if(reset_InputPin == 0)
        begin
            recvCount <= 0;
            stateCnt <= 0;
            
            csRAMSample_OutputPin <= 0;
            weRAMSampleSineW_OutputPin <= 0; 
            oeRAMSampleSineW_OutputPin <= 0;
            
            csRAMSineW_OutputPin <= 0;
            
            startFFT_OutputPin <= 0;
            
            UART_RdyClr_Wire <= 1; 
            
        end
        else
        begin
                
                case(stateCnt)
                    
                    0:begin
                        if((UART_RxRdyOut_Wire) == 1'h1)
                        begin
                            stateCnt <= (stateCnt + 1);
                            UART_RdyClr_Wire <= 1; 
                        end
                        else
                        begin
                            csRAMSample_OutputPin <= 0;
                            csRAMSineW_OutputPin <= 0;
                            
                            weRAMSampleSineW_OutputPin <= 0; 
                            oeRAMSampleSineW_OutputPin <= 0;
                            
                            UART_RdyClr_Wire <= 0;                          
                        end
                    end
                    
                    //Header
                    1:begin
                        if(UART_Dout_Wire == 8'hAA)
                        begin
                            stateCnt <= (stateCnt + 1);
                            byteCount <= 0;
                        end
                        else
                            stateCnt <= 0; 
                            
                        UART_RdyClr_Wire <= 0;    
                    end
                    
                    //Lenght
                    2:begin
                        if(UART_RxRdyOut_Wire == 1'h1)
                        begin
                            UART_RdyClr_Wire <= 1; 
                             
                            if(byteCount == 0)
                            begin 
                                dataLenght[15:8] <= UART_Dout_Wire;
                                byteCount <= 1; 
                            end
                            else
                            begin
                                dataLenght[7:0] <= UART_Dout_Wire;
                                stateCnt <= (stateCnt + 1);
                                byteCount <= 0; 
                            end
                        end
                        else
                           UART_RdyClr_Wire <= 0; 
                    end                    
                                        
                    //CMD
                    3:begin
                        if(UART_RxRdyOut_Wire == 1'h1)
                        begin
                            UART_RdyClr_Wire <= 1; 
                            
                            cmd <= UART_Dout_Wire;

                            recvCount <= 0;
                            stateCnt <= (stateCnt + 1); 
                            
                        end
                        else
                           UART_RdyClr_Wire <= 0;  
                    end
                    
                    //Check CMD
                    4:begin 
                        if(SAMPLE_DATA_CDM == (cmd & 8'hF0))
                        begin                        
                            stateCnt <= WRITE_RAM_STATE;
                            log2FFTSize_OutputPort <= (cmd & 8'h0F);
                            log2FFTSize_Register <= (cmd & 8'h0F);
                            csRAMSample_OutputPin <= 1;
                        end
                        else if(SINEWAVE_DATA_CMD == (cmd & 8'hF0))
                        begin
                            stateCnt <= WRITE_RAM_STATE;
                            csRAMSineW_OutputPin <= 1;
                        end
                        else if(START_FFT_CMD == (cmd & 8'hF0))
                        begin
                            stateCnt <= START_FFT_STATE;
                        end                     
                        else
                           stateCnt <= 0;
                           
                        UART_RdyClr_Wire <= 0;     
                    end
                    
                    START_FFT_STATE:begin
                        startFFT_OutputPin <= 1;
                        stateCnt <= START_FFT_STATE + 1;
                    end
                    
                    (START_FFT_STATE + 1):begin         //bu case 0'da halledilebilir mi?
                        startFFT_OutputPin <= 0;
                        stateCnt <= 0;    
                    end
                    
                    WRITE_RAM_STATE: begin
 
                        if(UART_RxRdyOut_Wire == 1'h1)
                        begin
                            UART_RdyClr_Wire <= 1; 
                             
                            if(byteCount == 0)
                            begin 
                                recvData16[15:8] <= UART_Dout_Wire;
                                byteCount <= 1; 
                            end
                            else
                            begin
                                recvData16[7:0] <= UART_Dout_Wire;                                
                                byteCount <= 0;
                                stateCnt <= (WRITE_RAM_STATE + 1); 
                                addRAMSampleSineW_OutputPort <= recvCount;
                            end                                
                        end
                        else
                            UART_RdyClr_Wire <= 0;                        
                                                
                    end
                    
                    (WRITE_RAM_STATE + 1):begin
                        UART_RdyClr_Wire <= 0;
                        
                        weRAMSampleSineW_OutputPin <= 1;
                        dataInRAMSampleSineW_OutputPort <= recvData16;                        
                                                
                        stateCnt <= (WRITE_RAM_STATE + 2);
                    end
                    
                    (WRITE_RAM_STATE + 2):begin
                        
                        recvCount <= (recvCount + 1);                         
                        stateCnt <= WRITE_RAM_STATE + 3; 
                    end
                    
                    (WRITE_RAM_STATE + 3):begin
                    
                        weRAMSampleSineW_OutputPin <= 0;
                                              
                        if(dataLenght == recvCount)
                        begin
                            csRAMSample_OutputPin <= 0;
                            csRAMSineW_OutputPin <= 0;

                            if(SAMPLE_DATA_CDM == (cmd & 8'hF0))
                                stateCnt <= START_FFT_STATE;
                            else
                                stateCnt <= 0; 
                        end
                        else
                           stateCnt <= WRITE_RAM_STATE;     
                    end
                    

                    default:                   
                        stateCnt <= 0;
                                      
 
            
        endcase
        
    end
    
    end
    
    
endmodule
